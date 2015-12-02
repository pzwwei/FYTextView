//
//  FYTextViewContent.m
//  FYTextView
//
//  Created by SunnyFeng on 11/20/15.
//  Copyright © 2015 SunnyFeng. All rights reserved.
//

#import "FYTextViewContent.h"
#import "FYTag.h"

#define DefaultTagContained 1

@implementation FYTextViewContent

- (instancetype)init{
    return [self initWithTextContent:@"" andTags:[NSArray array]];
}

- (instancetype)initWithTextContent:(NSString *)textContent andTags:(NSArray *)tags{
    self = [super init];
    if (self) {
        _textContent = textContent;
        _tags = tags;
    }
    return self;
}


- (instancetype)initWithTextContent:(NSString *)textContent andRanges:(NSArray< NSValue *> *)ranges{
    self = [super init];
    if (self) {
        _textContent = textContent;
        NSMutableArray *muArr = [[NSMutableArray alloc]initWithCapacity:ranges.count];
        for (NSValue *va in ranges) {
            NSRange range = [va rangeValue];
            NSString *text = [textContent substringWithRange:range];
            FYTag *tag = [[FYTag alloc]initWithText:text andLocation:range.location];
            [muArr addObject:tag];
        }
        _tags = [NSArray arrayWithArray:muArr];
    }
    return self;
}


- (NSString *)description{
    return [NSString stringWithFormat:@"text:%@ tags:%@",self.textContent,self.tags];
}

@end
