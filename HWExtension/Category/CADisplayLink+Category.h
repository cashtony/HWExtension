//
//  CADisplayLink+Block.h
//  HWExtension
//
//  Created by Wang,Houwen on 2018/6/27.
//  Copyright © 2018年 houwen.wang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef void (^BIDisplayLinkBlock)(CADisplayLink *displayLink);

@interface CADisplayLink (Category)

// blocks
@property (nonatomic, strong, readonly) NSMutableArray <BIDisplayLinkBlock>*blocks;

/**
 * 实例化方法
 *
 @param block 回调block
 @return instance
 */
+ (CADisplayLink *)displayLinkWithBlock:(BIDisplayLinkBlock)block;

// 重启 displayLink
- (void)resumWithFramesPerSecond:(NSInteger)framesPerSecond;

// 重启 displayLink
- (void)resumWithFrameInterval:(NSTimeInterval)frameInterval;

@end
