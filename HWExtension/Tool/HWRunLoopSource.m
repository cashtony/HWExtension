//
//  HWRunLoopSource.m
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/6/4.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import "HWRunLoopSource.h"

@interface HWRunLoopSource ()

@property (nonatomic, assign) void *info;    //
@property (nonatomic, assign) CFRunLoopSourceRef sourceRef;    //

@end

@implementation HWRunLoopSource

+ (instancetype)sourceWithInfo:(void *)info
{
    CFRunLoopSourceContext context = {0, info, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    
    HWRunLoopSource *source = nil;
    CFRunLoopSourceRef sourceRef = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    
    if (sourceRef) {
        source = [[self alloc] init];
        source.info = info;
        source.sourceRef = sourceRef;
        return source;
    }
    return nil;
}

- (void)signal
{
    CFRunLoopSourceSignal(self.sourceRef);
    CFRunLoopWakeUp(CFRunLoopGetCurrent());
}

- (BOOL)isValid
{
    return CFRunLoopSourceIsValid(self.sourceRef);
}

- (void)invalidate
{
    CFRunLoopSourceInvalidate(self.sourceRef);
}

@end
