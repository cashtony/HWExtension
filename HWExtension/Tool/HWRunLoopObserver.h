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

@property (nonatomic, assign, readonly) CFOptionFlags activities; //
@property (nonatomic, assign, readonly) BOOL repeats;             //

+ (instancetype)observerWithActivity:(CFOptionFlags)activities
                             repeats:(BOOL)repeats
                            callBack:(void (^)(HWRunLoopObserver *observer, CFRunLoopActivity activity))callBack;

- (void)observerRunLoop:(NSRunLoop *)runLoop forModes:(NSArray<NSRunLoopMode> *)modes;

@end

NS_ASSUME_NONNULL_END
