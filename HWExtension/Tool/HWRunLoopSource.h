//
//  HWRunLoopSource.h
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/6/4.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWRunLoopSource : NSObject

@property (nonatomic, assign, readonly) void *info;    //

+ (instancetype)sourceWithInfo:(void *)info;

- (void)signal;
- (BOOL)isValid;
- (void)invalidate;

@end
