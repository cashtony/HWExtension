//
//  HWInteractiveModalTransitionViewController.h
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/2/28.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//
//  可交互模态转场视图控制器

#import <UIKit/UIKit.h>
#import "HWInteractiveModalTransition.h"

@interface HWInteractiveModalTransitionViewController : UIViewController <HWInteractiveModalTransitionDelegate>

@property (nonatomic, strong) HWInteractiveModalTransition *interactiveModalTransition;

@end
