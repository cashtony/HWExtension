//
//  HWInteractiveModalTransitionViewController.m
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/2/28.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import "HWInteractiveModalTransitionViewController.h"

@interface HWInteractiveModalTransitionViewController ()

@end

@implementation HWInteractiveModalTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationCustom;
}

- (id<UIViewControllerTransitioningDelegate>)transitioningDelegate {
    return self.interactiveModalTransition;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
