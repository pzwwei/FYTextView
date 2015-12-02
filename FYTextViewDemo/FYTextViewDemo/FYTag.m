//
//  FYLabel.m
//  FYTextView
//
//  Created by SunnyFeng on 11/20/15.
//  Copyright © 2015 SunnyFeng. All rights reserved.
//

#import "FYTag.h"

@implementation FYTag

- (instancetype)initWithText:(NSString *)text andLocation:(NSUInteger)location{
    self = [super init];
    if (self) {
        _text = text;
        _location = location;
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"text:%@ location:%lu", self.text,(unsigned long)self.location];
}

@end
