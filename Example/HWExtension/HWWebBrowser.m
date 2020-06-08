//
//  HWWebBrowser.m
//  HWExtension_Example
//
//  Created by Wang,Houwen on 2019/4/15.
//  Copyright © 2019 wanghouwen. All rights reserved.
//

#import "HWWebBrowser.h"
#import "HWWebViewController.h"
#import "UIControl+Category.h"
#import "UIBarButtonItem+Category.h"

@interface HWWebBrowser () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *addressTextField;
@property (nonatomic, strong) HWWebViewController *webVC;

@end

@implementation HWWebBrowser

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webVC.view];
    [self addChildViewController:self.webVC];
    
    self.navigationItem.titleView = self.addressTextField;
    self.addressTextField.text = self.webVC.URLString;
    
    __weak typeof(self) ws = self;
    
    UIBarButtonItem *item0 = [UIBarButtonItem barButtonItemWithTitle:@"🏠" actionHandler:^(UIBarButtonItem *item, UIButton *customView)
                              {
                                  ws.webVC.URLString = @"https://www.baidu.com";
                                  ws.addressTextField.text = ws.webVC.URLString;
                              }];
    
    UIBarButtonItem *item1 = [UIBarButtonItem barButtonItemWithTitle:@"👈" actionHandler:^(UIBarButtonItem *item, UIButton *customView)
                              {
                                  [ws.webVC goBack];
                                  ws.addressTextField.text = ws.webVC.URLString;
                              }];
    
    UIBarButtonItem *item2 = [UIBarButtonItem barButtonItemWithTitle:@"👉" actionHandler:^(UIBarButtonItem *item, UIButton *customView)
                              {
                                  [ws.webVC goForward];
                                  ws.addressTextField.text = ws.webVC.URLString;
                              }];
    self.navigationItem.leftBarButtonItems = @[item0, item1, item2];
}

- (HWWebViewController *)webVC
{
    if (!_webVC)
    {
        _webVC = [[HWWebViewController alloc] initWithURL:@"https://www.baidu.com"];
    }
    return _webVC;
}

- (UITextField *)addressTextField
{
    if (!_addressTextField)
    {
        _addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 60, 34)];
        _addressTextField.delegate = self;
        _addressTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        _addressTextField.leftViewMode = UITextFieldViewModeAlways;
        _addressTextField.returnKeyType = UIReturnKeySearch;
        
        UIButton *right = [UIButton buttonWithType:UIButtonTypeSystem];
        [right setTitle:@"取消" forState:UIControlStateNormal];
        [right sizeToFit];
        right.frame = CGRectMake(0, 0, right.bounds.size.width + 20, 34);
        _addressTextField.rightView = right;
        
        [_addressTextField.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             if ([obj isKindOfClass:NSClassFromString(@"_UITextFieldContentView")])
             {
                 obj.backgroundColor = [UIColor lightGrayColor];
                 obj.layer.cornerRadius = 4;
                 obj.clipsToBounds = YES;
                 *stop = YES;
             }
         }];
        
        __weak typeof(self) ws = self;
        [right addEventsHandlerForControlEvents:UIControlEventTouchUpInside handler:^(__kindof UIControl *sender)
         {
             ws.addressTextField.text = ws.webVC.URLString;
             [ws.addressTextField endEditing:YES];
         }];
    }
    return _addressTextField;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.webVC.URLString = self.addressTextField.text;
    [self.addressTextField endEditing:YES];
    return YES;
}

@end
