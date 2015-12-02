//
//  FYTextView.m
//  FYTextView
//
//  Created by SunnyFeng on 11/20/15.
//  Copyright © 2015 SunnyFeng. All rights reserved.
//

#import "FYTextView.h"
#import "FYTag.h"

#define DefaultTagColor [UIColor orangeColor]
#define DefaultTagBgColor [UIColor clearColor]
#define DefaultPlaceholderColor [UIColor grayColor]
#define DefaultPlaceholder @"写点儿什么吧..."
#define DefaultFont [UIFont systemFontOfSize:20.f]
#define DefaultHasSpace 0;
@interface FYTextView ()<UITextViewDelegate>

@property (nonatomic) UILabel *placeholderLabel;
//@property (nonatomic) NSArray *tags;

@end

@implementation FYTextView


#pragma mark - initializer

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _placeholder = DefaultPlaceholder;
        _placeholderColor = DefaultPlaceholderColor;
        _tagColor = DefaultTagColor;
        _tagBgColor = DefaultTagBgColor;
        _minHeight = frame.size.height;
        _maxHeight = frame.size.height;
        _hasSpace = DefaultHasSpace;
        _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _placeholderLabel.text = _placeholder;
        _placeholderLabel.textColor = _placeholderColor;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.hidden = YES;
        _tagRanges = [[NSArray alloc]init];
        _content = [[FYTextViewContent alloc]init];
        [self addSubview:_placeholderLabel];
        
        _totalWords = 0;
#warning font
        self.font = DefaultFont;
        
        self.delegate = self;
        
    }
    return self;
}

- (void)setWithContent:(FYTextViewContent *)content{
    
}


#pragma mark - setter

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat newFrameHeight = frame.size.height;
    if (_minHeight > newFrameHeight) {
        _minHeight = newFrameHeight;
    }
    
    if (_maxHeight < newFrameHeight) {
        _maxHeight = newFrameHeight;
    }
}


- (void)setFont:(UIFont *)font{
    [super setFont:font];
}

- (void)setMaxHeight:(CGFloat)maxHeight{
    
    if (maxHeight < 0) {
        return;
    }
    
    CGFloat frameHeight = self.frame.size.height;
    
    if (frameHeight > 0) {
        if (maxHeight > frameHeight) {
            _maxHeight = maxHeight;
        }else{
            _maxHeight = frameHeight;
        }
    }else{
        _maxHeight = maxHeight;
    }
}

- (void)setMinHeight:(CGFloat)minHeight{
    
    if (minHeight < 0) {
        return;
    }
    
    CGFloat frameHeight = self.frame.size.height;
    

    if (frameHeight > 0) {
        if (minHeight < frameHeight) {
            _minHeight = minHeight;
        }else{
            _minHeight = frameHeight;
        }
    }else{
        _minHeight = minHeight;
    }

}


- (void)setPlaceholder:(NSString *)placeholder{
    if (!placeholder) {
        placeholder = @"";
    }
    _placeholder = placeholder;
    _placeholderLabel.text = _placeholder;
    [self setPlaceholderLayout];
    [self showPlaceholder];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    if (!placeholderColor) {
        return;
    }
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = _placeholderColor;
}


- (void)setViewHeight:(CGFloat)height{
    CGFloat originalHeight = self.frame.size.height;
    if (height == originalHeight) {
        return;
    }
    
    if ([self.fyDelegate respondsToSelector:@selector(textView:heightWillChange:)]) {
        [self.fyDelegate textView:self heightWillChange:height];
    }
    
    CGRect newFrame = self.frame;
    newFrame.size.height = height;
    self.frame = newFrame;
}

- (void)setContent:(FYTextViewContent *)content{
    _content = content;
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:@"" attributes:[self getTextAttributes]];
    NSMutableArray *tagLocs = [NSMutableArray array];
    NSUInteger startLoc = 0;
    for (FYTag *tag in content.tags) {
        if (![tag.text isEqualToString:[content.textContent substringWithRange:NSMakeRange(tag.location, tag.text.length)]]) {
            return;
        }
        NSString *subText = [content.textContent substringWithRange:NSMakeRange(startLoc, tag.location - startLoc)];
        if (subText.length) {
            [mutableAttributedString insertAttributedString:[[NSAttributedString alloc]initWithString:subText attributes:[self getTextAttributes]] atIndex:mutableAttributedString.length];
        }
        NSAttributedString *tagStr = [self getAttributedStringWithTagName:tag.text];
        [tagLocs addObject:[NSNumber numberWithUnsignedInteger:mutableAttributedString.length]];
        [mutableAttributedString insertAttributedString:tagStr atIndex:mutableAttributedString.length];
        startLoc = tag.location + tag.text.length;
    }
    NSString *subText = [content.textContent substringWithRange:NSMakeRange(startLoc, content.textContent.length - startLoc)];
    if (subText.length) {
        [mutableAttributedString insertAttributedString:[[NSAttributedString alloc]initWithString:subText attributes:[self getTextAttributes]] atIndex:mutableAttributedString.length];
    }
    self.tagRanges = tagLocs;
    UIFont *font = self.font;
    self.attributedText = mutableAttributedString;
    self.font = font;
    [self showPlaceholder];
    [self adjustViewHeight];
}

- (void)setTag:(FYTag *)tag{
    if (tag.location > self.content.textContent.length || !tag.text.length) {
        return;
    }
    NSUInteger realLoc = tag.location;
    NSUInteger locInArray = self.content.tags.count;
    NSMutableArray *muArr = [NSMutableArray arrayWithArray:self.tagRanges];
    
    for (NSUInteger i = 0; i < [self.content.tags count]; i++) {
        FYTag *t = self.content.tags[i];
        NSUInteger startLoc = t.location;//eg:0
        NSUInteger endLoc = startLoc + t.text.length - 1;//eg:0+5-1=4
        //如果当前tag跟之前的标签有重叠
        if (startLoc < tag.location&&tag.location <= endLoc) {//eg:(0,4]
            return;
        }
        if (tag.location > endLoc) {
            realLoc -= (t.text.length - 1);
        }else{
            locInArray = i;
            break;
        }
    }

    //调整self.tags和self.tagRanges数组中locInArray之后的每个元素的location值
    for (NSUInteger i = locInArray; i < self.content.tags.count; i++) {
        
        FYTag *t = self.content.tags[i];
        t.location = t.location + tag.text.length;
        
        NSNumber *numRange = self.tagRanges[i];
        NSUInteger loc = [numRange unsignedIntegerValue];
        loc += 1;
        numRange = [NSNumber numberWithUnsignedInteger:loc];
        [muArr replaceObjectAtIndex:i withObject:numRange];
    }
    
    //插入tag到self.tags数组中
    NSMutableArray *tags = [self.content.tags mutableCopy];
    [tags insertObject:tag atIndex:locInArray];
    self.content.tags = [tags copy];
    
    //更新self.content.textContent的值
    NSMutableString *mutableText = [self.content.textContent mutableCopy];
    [mutableText insertString:tag.text atIndex:tag.location];
    self.content.textContent = mutableText;
    
    
    //插入realLoc到self.tagRanges数组中
    [muArr insertObject:[NSNumber numberWithUnsignedInteger:realLoc] atIndex:locInArray];
    self.tagRanges = muArr;
    
   
    
    //制作标签
    UIFont *font = self.font;
    NSAttributedString *attributedStr = [self getAttributedStringWithTagName:tag.text];
    NSMutableAttributedString *mutableString;
    if (self.attributedText.length) {
        mutableString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
        [mutableString insertAttributedString:attributedStr atIndex:realLoc];
        self.attributedText = [mutableString copy];

    }else{
        
        self.attributedText = attributedStr;
        
        
    }
    self.font = font;
    
    [self showPlaceholder];
    [self adjustViewHeight];
    [self scrollRangeToVisible:self.selectedRange];
}


- (void)setTags:(NSArray *)tags{
    if (![tags.firstObject isKindOfClass:[FYTag class]]) {
        return;
    }
    for (FYTag *tag in tags) {
        [self setTag:tag];
    }
}


- (void)addTagToCurrentLocation:(NSString *)tagName{
    UIFont *font = self.font;
    NSRange selectedRange = self.selectedRange;
    NSMutableAttributedString *mutableStr = [self.attributedText mutableCopy];
    [mutableStr deleteCharactersInRange:selectedRange];
    self.attributedText = mutableStr;
    self.font = font;
    [self changeTextInRange:selectedRange replacementText:@""];
    FYTag *newTag = [[FYTag alloc]initWithText:tagName andLocation:selectedRange.location];
    for (NSUInteger i = 0; i < self.tagRanges.count;i++) {
        NSUInteger realLoc = [self.tagRanges[i] unsignedIntegerValue];
        if (realLoc < selectedRange.location) {
            FYTag *tag = self.content.tags[i];
            newTag.location += (tag.text.length - 1);
        }
    }
    [self setTag:newTag];
    self.selectedRange = NSMakeRange(selectedRange.location + 1, 0);
    
}

#pragma mark - pravite handle

///得到dj标签
- (NSAttributedString *)getAttributedStringWithTagName:(NSString *)tagName{
    NSDictionary *topicAttributes = [self getTagAttributes];
    NSTextAttachment * attachment = [[NSTextAttachment alloc] init];
    NSString *tagStr = tagName;
    if (self.hasSpace) {
        tagStr = [NSString stringWithFormat:@" %@ ",tagName];
    }
    UIImage *image = [self getImageWithString:tagStr andAttributes:topicAttributes];
    attachment.image = image;
    attachment.bounds = CGRectMake(0,self.font.descender, image.size.width, image.size.height);
    NSAttributedString * attachStr = [NSAttributedString attributedStringWithAttachment:attachment];
    return attachStr;
}

- (UIImage *)getImageWithString:(NSString *)string andAttributes:(NSDictionary *)attributes{
    NSAttributedString *attributedString = [[NSAttributedString  alloc]initWithString:string attributes:attributes];
    UIGraphicsBeginImageContextWithOptions(attributedString.size, NO, 0);
    if (self.tagBgImage) {
        [self.tagBgImage drawInRect:CGRectMake(0, 0, attributedString.size.width, attributedString.size.height)];
    }
    [attributedString drawAtPoint:CGPointMake(0, 0)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)adjustViewHeight{
    if (!self.autoIncrement) {
        return;
    }
    
    CGFloat heightToFit = [self calculateViewHeightToFit];
    
    CGFloat newHeight = heightToFit;
    
    if (heightToFit <= self.minHeight) {
        newHeight  = self.minHeight;
    }
    
    if (heightToFit >= self.maxHeight){
        if (heightToFit - self.maxHeight < self.font.lineHeight) {
            newHeight = heightToFit;
        }else{
            newHeight = self.maxHeight;
        }
       
    }
    
    [self setViewHeight:newHeight];
}


- (NSDictionary *)getTagAttributes{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    NSDictionary *attributes;
    if (!self.tagBgImage) {
        attributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.tagColor,NSBackgroundColorAttributeName:self.tagBgColor,NSParagraphStyleAttributeName:paragraphStyle};
    }else{
        attributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.tagColor,NSParagraphStyleAttributeName:paragraphStyle};
    }
    
    return attributes;
}

- (NSDictionary *)getTextAttributes{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    NSDictionary *attributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName:paragraphStyle};
    return attributes;
}

- (void)changeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSRange rangeInTextContent = range;
    
    NSMutableIndexSet *deleteIndexs = [NSMutableIndexSet indexSet];
    //调整tags数组
    for (NSUInteger i = 0; i < self.tagRanges.count; i ++ ) {
        NSUInteger tagLoc = [self.tagRanges[i] unsignedIntegerValue];
        FYTag *tag = self.content.tags[i];
        if (tagLoc < range.location) {
            rangeInTextContent.location += (tag.text.length - 1);
        }else if (tagLoc >= range.location && tagLoc < range.location + range.length) {
            [deleteIndexs addIndex:i];
            rangeInTextContent.length += (tag.text.length - 1);
        }else if(tagLoc >= range.location + range.length){
            tag.location += (text.length - rangeInTextContent.length);
            NSUInteger newTagLoc = [(NSNumber *)self.tagRanges[i] unsignedIntegerValue] + (text.length - range.length);
            self.tagRanges = [self arrayByReplaceObjectAtIndex:i inArray:self.tagRanges withObject:[NSNumber numberWithUnsignedInteger:newTagLoc]];
        }
    }
    
        //删除不要的tag
    NSMutableArray *newLocs = [self.tagRanges mutableCopy];
    [newLocs removeObjectsAtIndexes:deleteIndexs];
    self.tagRanges = newLocs;
    
    NSMutableArray *newTags = [self.content.tags mutableCopy];
    [newTags removeObjectsAtIndexes:deleteIndexs];
    self.content.tags = newTags;

    
    
    self.content.textContent = [self.content.textContent stringByReplacingCharactersInRange:rangeInTextContent withString:text];
    
}

#pragma mark - tool



- (NSArray *)arrayByReplaceObjectAtIndex:(NSUInteger)index inArray:(NSArray *)array withObject:(id)newElement{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
    [mutableArray replaceObjectAtIndex:index withObject:newElement];
    return [NSArray arrayWithArray:mutableArray];
}




#pragma mark caculate
- (CGFloat)calculateTextHeight{
    CGFloat newHeight = 0;
    if(self.text.length){
        
        newHeight = [self.attributedText boundingRectWithSize:CGSizeMake(self.textContainer.size.width - self.textContainer.lineFragmentPadding*2, 2000)
                                                      options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                      context:nil].size.height;
    }
    return newHeight;
}


- (CGFloat)calculateViewHeightToFit{
    return ([self calculateTextHeight] + self.textContainerInset.top + self.textContainerInset.bottom);

}



#pragma mark - layout

- (void)layoutSubviews{
    [super layoutSubviews];
}


- (void)setPlaceholderLayout{
    #warning font
    _placeholderLabel.font = self.font;
    _placeholderLabel.frame =CGRectMake(self.textContainerInset.left + self.textContainer.lineFragmentPadding, self.textContainerInset.top, self.textContainer.size.width, self.font.lineHeight);
}


- (void)showPlaceholder{
    if (self.text.length) {
        self.placeholderLabel.hidden = YES;
    }else{
        self.placeholderLabel.hidden = NO;
    }
}


#pragma mark - uiview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [self changeTextInRange:range replacementText:text];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    [self showPlaceholder];
    [self adjustViewHeight];
    NSLog(@"content:%@",self.content);
}

@end
