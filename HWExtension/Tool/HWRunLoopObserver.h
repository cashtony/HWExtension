//
//  HWRunLoopObserver.h
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/4/26.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  runLoop observer
 */
@interface HWRunLoopObserver : NSObject

@property (nonatomic, assign, readonly) CFRunLoopActivity activity;    //
@property (nonatomic, assign, readonly) void *info;                    //
@property (nonatomic, assign, readonly) BOOL repeats;                  //

+ (instancetype)observerWithActivity:(CFRunLoopActivity)act
                                info:(nullable void *)info
                             repeats:(BOOL)repeats
                            callBack:(void(^)(HWRunLoopObserver *observer, CFRunLoopActivity activity, void *info))callBack;

- (void)observerRunLoop:(NSRunLoop *)runLoop forMode:(NSRunLoopMode)mode;

@end

NS_ASSUME_NONNULL_END
