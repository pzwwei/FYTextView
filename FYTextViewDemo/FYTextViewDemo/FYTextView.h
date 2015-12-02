//
//  FYTextView.h
//  FYTextView
//
//  Created by SunnyFeng on 11/20/15.
//  Copyright © 2015 SunnyFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYTextViewContent.h"
#import "FYTag.h"

@class FYTextView;
@protocol FYTextViewDelegate <NSObject>

- (void)textView:(FYTextView *)textView heightWillChange:(CGFloat)height;
- (void)textView:(FYTextView *)textView wordsChanged:(CGFloat )words;

@end

@interface FYTextView : UITextView

@property (nonatomic) UIFont *textFont;


@property (nonatomic) NSInteger totalWords;

@property (nonatomic) FYTextViewContent *content;
@property (nonatomic) NSArray<NSNumber *> *tagRanges;

- (void)setContent:(FYTextViewContent *)content;
- (void)setTag:(FYTag *)tag;
- (void)setTags:(NSArray *)tags;
- (void)addTagToCurrentLocation:(NSString *)tagName;

@property (nonatomic) NSString *placeholder;
@property (nonatomic) UIColor *placeholderColor;



@property (nonatomic) UIColor *tagColor;
@property (nonatomic) UIColor *tagBgColor;
@property (nonatomic) UIImage *tagBgImage;
@property (nonatomic) BOOL hasSpace;

@property (nonatomic) BOOL autoIncrement;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic,readonly) CGFloat textHeight;
@property (nonatomic) CGFloat viewHeight;

@property (nonatomic) id <FYTextViewDelegate> fyDelegate;




@end
