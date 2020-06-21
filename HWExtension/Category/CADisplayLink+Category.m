//
//  CADisplayLink+Block.m
//  HWExtension
//
//  Created by Wang,Houwen on 2018/6/27.
//  Copyright © 2018年 houwen.wang. All rights reserved.
//

#import "CADisplayLink+Category.h"
#import <objc/runtime.h>

@interface BIDisplayLinkTarget : NSObject

@property (nonatomic, strong) NSMutableArray <BIDisplayLinkBlock>*blocks;

+ (instancetype)targetWithBlock:(BIDisplayLinkBlock)block;

@end

@implementation BIDisplayLinkTarget

+ (instancetype)targetWithBlock:(BIDisplayLinkBlock)block {
    BIDisplayLinkTarget *target = [[self alloc] init];
    !block ? : [target.blocks addObject:block];
    return target;
}

- (void)displayCallback:(CADisplayLink *)sender {
    for (BIDisplayLinkBlock block in self.blocks) {
        block(sender);
    }
}

- (NSMutableArray<BIDisplayLinkBlock> *)blocks {
    if (!_blocks) {
        _blocks = [NSMutableArray array];
    }
    return _blocks;
}

@end

@interface CADisplayLink ()

@property (nonatomic, strong) BIDisplayLinkTarget *target;

@end

@implementation CADisplayLink (Category)

+ (CADisplayLink *)displayLinkWithBlock:(BIDisplayLinkBlock)block {
    BIDisplayLinkTarget *target = [BIDisplayLinkTarget targetWithBlock:block];
    CADisplayLink *displayLink = [self displayLinkWithTarget:target selector:@selector(displayCallback:)];
    displayLink.target = target;
    return displayLink;
}

- (NSMutableArray<BIDisplayLinkBlock> *)blocks {
    return self.target.blocks;
}

- (BIDisplayLinkTarget *)target {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTarget:(BIDisplayLinkTarget *)target {
    objc_setAssociatedObject(self, @selector(target), target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 重启 displayLink
- (void)resumWithFramesPerSecond:(NSInteger)framesPerSecond
{
    self.paused = YES;
    
    if (@available(iOS 10.0, *)) {
        self.preferredFramesPerSecond = framesPerSecond;
    } else {
        self.frameInterval = (NSInteger)(ceil(60.f / (framesPerSecond != 0.f ? framesPerSecond : 1.f)));
    }
    
    self.paused = NO;
}

// 重启 displayLink
- (void)resumWithFrameInterval:(NSTimeInterval)frameInterval
{
    self.paused = YES;
    
    if (@available(iOS 10.0, *)) {
        self.preferredFramesPerSecond = (NSInteger)(ceil(60.f / (frameInterval != 0.f ? frameInterval : 1.f)));
    } else {
        self.frameInterval = frameInterval;
    }
    
    self.paused = NO;
}

@end
