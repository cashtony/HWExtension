//
//  HWRouterSubViewController3.m
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/3/6.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import "HWRouterSubViewController3.h"
#import "HWRouter.h"
#import "HWCategorys.h"

@interface HWRouterSubViewController3 ()

@property (nonatomic, strong) UILabel *label;    //

@end

@implementation HWRouterSubViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass(self.class);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.label == nil) {
        self.label = [UILabel labelWithText:nil font:[UIFont systemFontOfSize:17] textColor:[UIColor orangeColor]];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        [self.view addSubview:self.label];
    }
    self.label.text = [NSString stringWithFormat:@"para1:%@\npara2:%@\npara3:%@", @(self.para1), self.para2, self.para3];
    self.label.frame = self.view.bounds;
}

#pragma mark - HWRouteDelegate

// 允许被router赋值的属性名
+ (NSArray<NSString *> *)publicPropertyNames {
    return @[@"para1", @"para2", @"para3"];
}

+ (NSString *)replacedParameterNameForParameterNameInURL:(NSString *)parameterNameInURL {
    if ([parameterNameInURL isEqualToString:@"p1"]) {
        return @"para1";
    } else if ([parameterNameInURL isEqualToString:@"p2"]) {
        return @"para2";
    } else if ([parameterNameInURL isEqualToString:@"p3"]) {
        return @"para3";
    }
    return parameterNameInURL;
}

+ (HWRouteActionPolicy)decidePolicyForRouteWithParameters:(NSDictionary<NSString *,id> *)parameters module:(NSString *)module {
    return [module isEqualToString:@"Other"] ? HWRouteActionPolicyAllow : HWRouteActionPolicyCancel;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.navigationController == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
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
