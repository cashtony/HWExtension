//
//  HWRootViewController.m
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/3/2.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import "HWRootViewController.h"
#import "HWGraphicViewController.h"
#import "HWSandboxBrowserViewController.h"

@interface HWRootViewController ()

@end

@implementation HWRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    if (!self.viewControllers.count) {
        
        self.tabBar.barTintColor = [UIColor whiteColor];
        
        NSArray <Class>*vcClss = @[[HWGraphicViewController class], [HWSandboxBrowserViewController class]];
        NSArray <NSString *>*vcNames = @[@"图表", @"沙盒"];
        
        NSMutableArray <UINavigationController *>*vcs = [NSMutableArray array];
        
        for (Class cls in vcClss) {
            
            UIViewController *vc = [[cls alloc] init];
            vc.edgesForExtendedLayout = UIRectEdgeNone;
            
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
            nvc.tabBarItem = [[UITabBarItem alloc] initWithTitle:vcNames[[vcClss indexOfObject:cls]] image:nil selectedImage:nil];
            nvc.navigationBar.barTintColor = [UIColor whiteColor];
            [vcs addObject:nvc];
        }
        
        [self setViewControllers:vcs animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
