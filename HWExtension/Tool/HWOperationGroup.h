//
//  HWOperationHelper.h
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/4/26.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HWAsynchronousOperation;

typedef void(^HWAsynchronousOperationBlock)(__kindof HWAsynchronousOperation *operation, dispatch_block_t complete);

#pragma mark -
#pragma mark - asynchronous operation

@interface HWAsynchronousOperation : NSOperation

@property (nonatomic, copy, readonly) HWAsynchronousOperationBlock executionBlock;    //

+ (instancetype)asynchronousOperationWithBlock:(HWAsynchronousOperationBlock)block;

@end

#pragma mark -
#pragma mark - operation group

@interface HWOperationGroup : NSObject

- (void)syncOperations:(NSArray <__kindof HWAsynchronousOperation *>*)ops
            willBengin:(void(^)(__kindof HWAsynchronousOperation *operation))willBengin
              complete:(void(^)(__kindof HWAsynchronousOperation *operation))complete
       orderedComplete:(void(^)(__kindof HWAsynchronousOperation *operation))orderedComplete
           allComplete:(void(^)(void))allComplete;

- (void)asyncOperations:(NSArray <__kindof HWAsynchronousOperation *>*)ops
             willBengin:(void(^)(__kindof HWAsynchronousOperation *operation))willBengin
               complete:(void(^)(__kindof HWAsynchronousOperation *operation))complete
        orderedComplete:(void(^)(__kindof HWAsynchronousOperation *operation))orderedComplete
            allComplete:(void(^)(void))allComplete;

@end

NS_ASSUME_NONNULL_END
