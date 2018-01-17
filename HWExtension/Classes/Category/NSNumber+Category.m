//
//  NSNumber+Category.m
//  HWExtension
//
//  Created by houwen.wang on 2016/3/27.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "NSNumber+Category.h"

@implementation NSNumber (Category)

// 和 0.0 比较
- (NSComparisonResult)comparisonZero {
    return [self compare:@(0.0)];
}

@end
