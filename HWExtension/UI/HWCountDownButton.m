//
//  HWCountDownButton.m
//  HWExtension
//
//  Created by houwen.wang on 2017/10/24.
//  Copyright © 2017年 houwen.wang. All rights reserved.
//

#import "HWCountDownButton.h"

@interface HWCountDownButton ()

@property (nonatomic, copy) void(^updateBlock)(HWCountDownButton *button, NSTimeInterval remainingTimeInterval, BOOL didFinish);    

@property (nonatomic, assign) BOOL didPause;
@property (nonatomic, assign) BOOL didFinish;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSDate *fireDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *stopDate;

@property (nonatomic, assign) NSTimeInterval totalTime;       // 总时间
@property (nonatomic, assign) NSTimeInterval timeInterval;    // 倒计时间隔
@property (nonatomic, assign) NSTimeInterval remainingTime;   // 剩余时间

@end

@implementation HWCountDownButton

- (instancetype)init {
    if (self=[super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    HWCountDownButton *btn = [super buttonWithType:buttonType];
    if (btn) {
        [btn setup];
    }
    return btn;
}

- (void)setup {
    if ([self backgroundImageForState:UIControlStateNormal] == nil) {
        [self setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f]
                   forState:UIControlStateDisabled];
        self.didFinish = YES;
        self.didPause = NO;
    }
}

- (void)startCountDownFromTotalTime:(NSTimeInterval)totalTime
                       timeInterval:(NSTimeInterval)timeInterval
                              block:(void(^)(HWCountDownButton *button, NSTimeInterval remainingTime, BOOL didFinish))block {
    
    [self stopTimer];
    self.enabled = NO;
    
    self.updateBlock = block;
    
    self.totalTime = totalTime;
    self.timeInterval = timeInterval;
    self.remainingTime = totalTime;
    
    self.fireDate = [NSDate date];
    self.endDate = [self.fireDate dateByAddingTimeInterval:totalTime];
    
    [self resume];
}

- (void)resume {
    if (self.stopDate) {
        NSTimeInterval stopInterval = [[NSDate date] timeIntervalSinceDate:self.stopDate];
        self.endDate = [self.endDate dateByAddingTimeInterval:(stopInterval - self.timeInterval)];
        self.stopDate = nil;
    }
    [self startTimer];
}

- (void)pause {
    
    [self stopTimer];
    
    if (self.stopDate == nil) {
        self.stopDate = [NSDate date];
    }
    
    if (self.isCounting) {
        self.didFinish = NO;
    } else {
        self.didFinish = YES;
    }
}

- (void)finish {
    [self stopTimer];
    self.didFinish = YES;
    self.remainingTime = 0.0;
    self.enabled = YES;
}

- (NSTimeInterval)remainingTime {
    return self.endDate ? [self.endDate timeIntervalSinceDate:[NSDate date]] : 0.0f;
}

- (BOOL)isCounting {
    return (self.timer == nil ? NO : YES);
}

- (void)handlerTimerAction {
    
    self.remainingTime = self.remainingTime;
    self.remainingTime -= _timeInterval;
    
    if (self.remainingTime <= 0.0f) {
        [self finish];
        if (self.updateBlock) {
            self.updateBlock(self, 0.0f, YES);
        }
        return;
    }
    
    if (self.updateBlock) {
        self.updateBlock(self, self.remainingTime, NO);
    }
}

- (void)startTimer {
    if (self.timer == nil) {
        __weak typeof(self) ws = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval fireDate:[NSDate date] repeats:YES block:^(NSTimer *timer) {
            __strong typeof(ws) ss = ws;
            [ss handlerTimerAction];
        }];
    }
    self.didPause = NO;
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.didPause = YES;
}

- (void)dealloc {
    [self stopTimer];
}

@end
