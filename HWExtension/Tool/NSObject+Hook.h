//
//  NSObject+Hook.h
//  HWRuntime_Example
//
//  Created by Wang,Houwen on 2019/8/17.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HWMethodHookTime) {
    HWMethodHookTimeAfter,
    HWMethodHookTimeBefore
};

@interface NSObject (Hook)

+ (void)hookMethod:(SEL)sel
          instance:(BOOL)instance
            before:(void (^)(id target, SEL sel, va_list args))before
             after:(void (^)(id target, SEL sel, va_list args))after;

@end

NS_ASSUME_NONNULL_END
