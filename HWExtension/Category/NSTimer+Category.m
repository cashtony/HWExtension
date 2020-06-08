//
//  NSTimer+Category.m
//  HWExtension
//
//  Created by houwen.wang on 2016/12/6.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "NSTimer+Category.h"

@implementation NSTimer (Category)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval fireDate:(NSDate *)date repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block {
    NSTimer *timer = [self scheduledTimerWithTimeInterval:interval
                                                   target:self
                                                 selector:@selector(schedule:)
                                                 userInfo:block
                                                  repeats:repeats];
    timer.fireDate = date;
    return timer;
}

+ (void)schedule:(NSTimer *)sender {
    void (^block)(NSTimer *timer) = sender.userInfo;
    if (block) {
        block(sender);
    }
}

@end
