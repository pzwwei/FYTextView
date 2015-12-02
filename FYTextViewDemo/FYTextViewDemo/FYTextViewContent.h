//
//  FYTextViewContent.h
//  FYTextView
//
//  Created by SunnyFeng on 11/20/15.
//  Copyright © 2015 SunnyFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYTextViewContent : NSObject

@property (nonatomic) BOOL tagsContainedInContent;

@property (nonatomic) NSString *textContent;
@property (nonatomic) NSArray *tags;

- (instancetype)initWithTextContent:(NSString *)textContent andTags:(NSArray *)tags;

- (instancetype)initWithTextContent:(NSString *)textContent andRanges:(NSArray< NSValue *> *)ranges;

@end
