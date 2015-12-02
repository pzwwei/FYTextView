//
//  ViewController.m
//  FYTextView
//
//  Created by SunnyFeng on 11/20/15.
//  Copyright © 2015 SunnyFeng. All rights reserved.
//

#import "ViewController.h"
#import "FYTextView.h"
@interface ViewController ()<FYTextViewDelegate>
@property (nonatomic) FYTextView *testView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FYTextView *testView = [[FYTextView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width - 20, 50)];
    testView.font = [UIFont systemFontOfSize:14.f];
    testView.textContainerInset = UIEdgeInsetsMake(3, 5, 3, 5);
    testView.hasSpace = YES;
    testView.tagBgColor = [UIColor brownColor];
    testView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
    UIImage *tagBgImage = [[UIImage imageNamed:@"bg"]resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch];
    testView.tagBgImage = tagBgImage;
    testView.tagColor = [UIColor whiteColor];
    testView.autoIncrement = NO;
    testView.maxHeight = 80;
    [testView setPlaceholder:@"Hahahaha..."];
    testView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    testView.fyDelegate = self;
    [self.view addSubview:testView];

    self.testView = testView;
    
    UIView *tagView = [[UIView alloc]initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 80)];
    tagView.tag = 520;
    
    CGFloat tagWidth = 70.0;
    CGFloat space = 10.0;
    NSUInteger tagNumPerLine = (tagView.bounds.size.width - 20 + space)/tagWidth;
    for (NSUInteger m = 0; m < 10; m++) {
        NSUInteger i = m/tagNumPerLine;
        NSUInteger j = m%tagNumPerLine;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(5 + j*(tagWidth + space), 5 + i*20, tagWidth, 20);
        btn.tag = m;
        [btn setTitle:[NSString stringWithFormat:@"FYTag%lu",(unsigned long)m] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [tagView addSubview:btn];
        [btn sizeToFit];
    }
    
    [self.view addSubview:tagView];
    
   
 
//    FYTextViewContent *content = [[FYTextViewContent alloc]initWithTextContent:@"hello    nihao" andRanges:@[[NSValue valueWithRange:NSMakeRange(0, 1)],[NSValue valueWithRange:NSMakeRange(4, 1)]]];
//    [testView setContent:content];
    
}

- (void)btnClick:(UIButton *)btn{
    [self.testView addTagToCurrentLocation:btn.titleLabel.text];
}


#pragma mark - fytextview delegate
- (void)textView:(FYTextView *)textView heightWillChange:(CGFloat)height{
    CGFloat diff = height - textView.bounds.size.height;
    UIView *tagView = [self.view viewWithTag:520];
    CGRect frame = tagView.frame;
    frame.origin.y += diff;
    tagView.frame = frame;
}
- (void)textView:(FYTextView *)textView wordsChanged:(CGFloat )words{
    
}
@end
