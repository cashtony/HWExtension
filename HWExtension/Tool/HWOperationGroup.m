//
//  HWOperationHelper.m
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/4/26.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import "HWOperationGroup.h"

#pragma mark -
#pragma mark - asynchronous operation

@interface HWAsynchronousOperation ()

@property (nonatomic, copy) HWAsynchronousOperationBlock executionBlock;               //
@property (nonatomic, copy) void (^willBegin)(HWAsynchronousOperation *operation);     //
@property (nonatomic, copy) void (^didCompleted)(HWAsynchronousOperation *operation);  //

// private
@property (nonatomic, copy) dispatch_block_t completionSignal;                  //
@property (nonatomic, strong) dispatch_semaphore_t semaphore;                   //

@end

@implementation HWAsynchronousOperation

+ (instancetype)asynchronousOperationWithBlock:(HWAsynchronousOperationBlock)block {
    HWAsynchronousOperation *op = [[self alloc] init];
    op.executionBlock = block;
    return op;
}

- (void)start {
    
    if (self.semaphore) return;
    
    self.semaphore = dispatch_semaphore_create(0);
    
    !self.willBegin ? : self.willBegin(self);
    
    // do block
    self.executionBlock(self, self.completionSignal);
    
    // suspend
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    self.semaphore = nil;
    
    !self.didCompleted ? : self.didCompleted(self);
    
    [super start];
}

- (dispatch_block_t)completionSignal {
    if (!_completionSignal) {
        __weak typeof(self) ws = self;
        _completionSignal = ^(void) {
            __strong typeof(ws) ss = ws;
            dispatch_semaphore_signal(ss.semaphore);
        };
    }
    return _completionSignal;
}

- (void)dealloc {
}

@end

#pragma mark -
#pragma mark - operation group

@implementation HWOperationGroup

- (void)syncOperations:(NSArray <__kindof HWAsynchronousOperation *>*)ops
            willBengin:(void(^)(__kindof HWAsynchronousOperation *operation))willBengin
              complete:(void(^)(__kindof HWAsynchronousOperation *operation))complete
       orderedComplete:(void(^)(__kindof HWAsynchronousOperation *operation))orderedComplete
           allComplete:(void(^)(void))allComplete {
    
    [self startOperations:[ops mutableCopy]
                    async:NO
               willBengin:willBengin
                 complete:complete
          orderedComplete:orderedComplete
              allComplete:allComplete];
}

- (void)asyncOperations:(NSArray <__kindof HWAsynchronousOperation *>*)ops
             willBengin:(void(^)(__kindof HWAsynchronousOperation *operation))willBengin
               complete:(void(^)(__kindof HWAsynchronousOperation *operation))complete
        orderedComplete:(void(^)(__kindof HWAsynchronousOperation *operation))orderedComplete
            allComplete:(void(^)(void))allComplete {
    
    [self startOperations:[ops mutableCopy]
                    async:YES
               willBengin:willBengin
                 complete:complete
          orderedComplete:orderedComplete
              allComplete:allComplete];
    
}

#pragma mark -
#pragma mark private

- (void)startOperations:(NSMutableArray <HWAsynchronousOperation *>*)ops
                  async:(BOOL)async
             willBengin:(void(^)(HWAsynchronousOperation *operation))willBengin
               complete:(void(^)(HWAsynchronousOperation *operation))complete
        orderedComplete:(void(^)(HWAsynchronousOperation *operation))orderedComplete
            allComplete:(void(^)(void))allComplete {
    
    if (!async) {
        [self __syncStartOperations:ops
                         willBengin:willBengin
                           complete:complete
                    orderedComplete:orderedComplete
                        allComplete:allComplete];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self __syncStartOperations:ops
                             willBengin:willBengin
                               complete:complete
                        orderedComplete:orderedComplete
                            allComplete:allComplete];
        });
    }
}

- (void)__syncStartOperations:(NSMutableArray <HWAsynchronousOperation *>*)ops
                   willBengin:(void(^)(HWAsynchronousOperation *operation))willBengin
                     complete:(void(^)(HWAsynchronousOperation *operation))complete
              orderedComplete:(void(^)(HWAsynchronousOperation *operation))orderedComplete
                  allComplete:(void(^)(void))allComplete {
    
    if (ops.count > 0) {
        
        NSMutableArray <NSOperation *>*orderedOps = [NSMutableArray array];
        
        for (int i=0; i<ops.count; i++) {
            
            __weak HWAsynchronousOperation *wOp = ops[i];
            NSBlockOperation *orderedOp = [NSBlockOperation blockOperationWithBlock:^{
                __strong HWAsynchronousOperation *sOp = wOp;
                
                !orderedComplete ? : orderedComplete(sOp);
            }];
            
            if (i) {
                [orderedOp addDependency:orderedOps[i-1]];
            }
            
            [orderedOps addObject:orderedOp];
        }
        
        NSOperationQueue *operationsQueue = [[NSOperationQueue alloc] init];
        NSOperationQueue *orderedCompleteQueue = [[NSOperationQueue alloc] init];
        
        for (HWAsynchronousOperation *op in ops) {
            
            op.willBegin = ^(HWAsynchronousOperation *op_t) {
                !willBengin ? : willBengin(op_t);
            };
            
            __weak typeof(ops) wOps = ops;
            op.didCompleted = ^(HWAsynchronousOperation *op_t) {
                __strong typeof(wOps) sOps = wOps;
                
                !complete ? : complete(op_t);
                
                NSUInteger idx = [sOps indexOfObject:op_t];
                [orderedCompleteQueue addOperation:orderedOps[idx]];
            };
            
            [operationsQueue addOperation:op];
        }
        
        [operationsQueue waitUntilAllOperationsAreFinished];
        [orderedCompleteQueue waitUntilAllOperationsAreFinished];
        
        [orderedOps removeAllObjects];
        [ops removeAllObjects];
        
        !allComplete ? : allComplete();
    }
}

- (void)dealloc {
}

@end
