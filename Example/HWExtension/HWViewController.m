//
//  HWViewController.m
//  HWExtension
//
//  Created by wanghouwen on 01/10/2018.
//  Copyright (c) 2018 wanghouwen. All rights reserved.
//

#import "HWViewController.h"
#import "UIWebView+Category.h"

@interface HWViewController ()<HWUIWebViewHookDelegate>

@property (nonatomic, strong) UIWebView *webView;    //

@end

@implementation HWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] init];
    self.webView.hookDelegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:self.webView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

- (void)webView:(UIWebView *)webview javaScriptContextDidChanged:(JSContext *)newJSContext isMainFrame:(BOOL)isMainFrame {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
