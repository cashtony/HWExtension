//
//  HWInteractiveModalTransition.h
//  HWExtension
//
//  Created by houwen.wang on 2016/10/21.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//
//  可交互模态转场

#import <Foundation/Foundation.h>
#import "UIGestureRecognizer+Category.h"

@class HWModalTransitioningContext, HWInteractiveModalTransition;

typedef NS_ENUM(NSInteger, HWModalTransitionOperation) {
    HWModalTransitionOperationPresent,
    HWModalTransitionOperationDismiss,
};

typedef NS_ENUM(NSInteger, HWTransitionEndType) {
    HWTransitionEndTypeFinish,
    HWTransitionEndTypeCancel,
};

typedef void(^HWCompleteBlock)(void);
typedef void(^HWInteractiveUpdateBlock)(HWModalTransitionOperation operation, CGFloat percentComplete, BOOL end, HWTransitionEndType endType);
typedef void(^HWTransitionAnimatorBlock)(HWModalTransitioningContext *context,
                                         HWInteractiveUpdateBlock interactiveUpdate,
                                         HWCompleteBlock completeAnimateTransition);

/**
 *  UIViewController 实现自定义模态转场效果，需以下2个步骤
 *  1、vc.modalPresentationStyle = UIModalPresentationCustom
 *  2、vc.transitioningDelegate = protocol.interactiveModalTransition
 *
 *  以上步骤须在[vc presentViewController:animated:completion:]之前已完成
 */
@protocol HWInteractiveModalTransitionDelegate <NSObject>

@property (nonatomic, strong) HWInteractiveModalTransition *interactiveModalTransition;

@end

@interface HWModalTransitioningContext : NSObject

@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) UIViewController *fromVC;
@property (nonatomic, strong, readonly) UIViewController *toVC;

@property (nonatomic, strong, readonly) UIViewController *presentedVC;
@property (nonatomic, strong, readonly) UIViewController *presentingVC;
@property (nonatomic, strong, readonly) UIViewController *sourceVC;

@end

@interface HWTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, readonly) NSTimeInterval duration;    
@property (nonatomic, copy) HWTransitionAnimatorBlock animate;      // custom your animations

+ (instancetype)transitionAnimatorWithDuration:(NSTimeInterval)duration animate:(HWTransitionAnimatorBlock)animate;

@end

@interface HWInteractiveModalTransition : NSObject <UIViewControllerTransitioningDelegate>

// animator
@property (nonatomic, strong, readonly) HWTransitionAnimator *presentAnimator;  // present
@property (nonatomic, strong, readonly) HWTransitionAnimator *dismissAnimator;  // dismiss

+ (instancetype)transitionWithPresentAnimator:(HWTransitionAnimator *)presentAnimator
                              dismissAnimator:(HWTransitionAnimator *)dismissAnimator;
@end
