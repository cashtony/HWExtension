//
//  HXCountDownButton.h
//  HWExtension
//
//  Created by houwen.wang on 2017/10/24.
//  Copyright © 2017年 houwen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSTimer+Category.h"

@interface HWCountDownButton : UIButton

@property (nonatomic, assign, readonly) BOOL didPause;   //
@property (nonatomic, assign, readonly) BOOL didFinish;   //
@property (nonatomic, assign, readonly) BOOL isCounting;  //

@property (nonatomic, assign, readonly) NSTimeInterval totalTime;       // 总时间
@property (nonatomic, assign, readonly) NSTimeInterval timeInterval;    // 倒计时间隔
@property (nonatomic, assign, readonly) NSTimeInterval remainingTime;   // 剩余时间

- (void)startCountDownFromTotalTime:(NSTimeInterval)totalTime
                       timeInterval:(NSTimeInterval)timeInterval
                              block:(void(^)(HWCountDownButton *button, NSTimeInterval remainingTime, BOOL didFinish))block;

- (void)resume;  // 继续倒计时
- (void)pause;   // 暂停倒计时
- (void)finish;  // 结束倒计时

@end
