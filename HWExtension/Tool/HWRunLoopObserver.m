//
//  HWRunLoopObserver.m
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/4/26.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import "HWRunLoopObserver.h"
#import <objc/runtime.h>

@interface HWRunLoopObserver ()

@property (nonatomic, assign) CFOptionFlags activities;         //
@property (nonatomic, assign) BOOL repeats;                     //
@property (nonatomic, assign) CFRunLoopObserverRef observerRef; //

@end

@implementation HWRunLoopObserver

+ (instancetype)observerWithActivity:(CFOptionFlags)activities
                             repeats:(BOOL)repeats
                            callBack:(void (^)(HWRunLoopObserver *observer, CFRunLoopActivity activity))callBack;
{
    __block HWRunLoopObserver *observer = nil;
    CFRunLoopObserverRef observerRef = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
                                                                          activities,
                                                                          repeats,
                                                                          0, ^(CFRunLoopObserverRef observerRef,
                                                                               CFRunLoopActivity activity) {
                                                                              !callBack ?: callBack(observer, activity);
                                                                          });
    if (observerRef) {
        observer = [[self alloc] init];
        observer.observerRef = observerRef;
        observer.activities = activities;
        observer.repeats = repeats;
        return observer;
    }
    return nil;
}

- (void)observerRunLoop:(NSRunLoop *)runLoop forModes:(NSArray<NSRunLoopMode> *)modes {
    for (NSRunLoopMode m in modes) {
        CFRunLoopAddObserver([runLoop getCFRunLoop], self.observerRef, (__bridge CFRunLoopMode)m);
    }
}

@end
