//
//  HWInteractiveModalTransitionNavigationController.h
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/2/28.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//
//  可交互模态转场导航视图控制器

#import <UIKit/UIKit.h>
#import "HWInteractiveModalTransition.h"

@interface HWInteractiveModalTransitionNavigationController : UINavigationController <HWInteractiveModalTransitionDelegate>

@property (nonatomic, strong) HWInteractiveModalTransition *interactiveModalTransition;

@end
