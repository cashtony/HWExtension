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

@property (nonatomic, assign) CFRunLoopActivity activity;    //
@property (nonatomic, assign) void *info;                    //
@property (nonatomic, assign) BOOL repeats;                  //

@property (nonatomic, assign) CFRunLoopObserverRef observerRef;    //

@end

@implementation HWRunLoopObserver

+ (instancetype)observerWithActivity:(CFRunLoopActivity)act
                                info:(nullable void *)info
                             repeats:(BOOL)repeats
                            callBack:(void(^)(HWRunLoopObserver *observer, CFRunLoopActivity activity, void *info))callBack;
{
    CFRunLoopObserverContext context = {0, info, NULL, NULL, NULL};
    
    HWRunLoopObserver *observer = nil;
    
    void (^block_t)(CFRunLoopObserverRef, CFRunLoopActivity, void *) = ^(CFRunLoopObserverRef observerRef,
                                                                         CFRunLoopActivity activity,
                                                                         void *info)
    {
        if (callBack) {
            callBack(observer, activity, info);
        }
    };
    IMP imp = imp_implementationWithBlock(block_t);
    
    CFRunLoopObserverRef observerRef = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                               act,
                                                               repeats,
                                                               0,
                                                               (CFRunLoopObserverCallBack)imp,
                                                               &context);
    if (observerRef) {
        observer = [[self alloc] init];
        observer.observerRef = observerRef;
        observer.activity = act;
        observer.info = info;
        observer.repeats = repeats;
        return observer;
    }
    return nil;
}

- (void)observerRunLoop:(NSRunLoop *)runLoop forMode:(NSRunLoopMode)mode
{
    CFRunLoopAddObserver([runLoop getCFRunLoop], self.observerRef, (__bridge CFRunLoopMode)mode);
}

@end
