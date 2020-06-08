//
//  HWWebViewController.h
//  HWExtension
//
//  Created by houwen.wang on 16/4/25.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//
//  内嵌webview的视图控制器

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class HWWebViewController;

#define kWebKitAvailable (NSClassFromString(@"WKWebView") ? YES : NO)

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HWWebViewLoadStatus) {
    HWWebViewLoadStatusUnLoad,
    HWWebViewLoadStatusLoading,
    HWWebViewLoadStatusSuccess,
    HWWebViewLoadStatusFailed,
};

typedef NS_ENUM(NSInteger, HWWebViewNavigationType) {
    HWWebViewNavigationTypeLinkClicked,
    HWWebViewNavigationTypeFormSubmitted,
    HWWebViewNavigationTypeBackForward,
    HWWebViewNavigationTypeReload,
    HWWebViewNavigationTypeFormResubmitted,
    HWWebViewNavigationTypeOther
};

typedef void (^HWWebViewLoadStatusBlock)(__kindof HWWebViewController *webVC, NSString *__nullable identifier, HWWebViewLoadStatus status, NSError *__nullable error);

@protocol HWWebViewControllerDelegate;

@interface HWWebViewController : UIViewController <WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate>

@property (nonatomic, copy, nullable) NSString *URLString;
@property (nonatomic, copy, nullable) NSString *HTMLString;

@property (nonatomic, copy, nullable) NSString *identifier;

@property (nonatomic, weak) id <HWWebViewControllerDelegate> delegate;
@property (nonatomic, copy) HWWebViewLoadStatusBlock loadStatusBlock;

// WKWebView
// kWebKitAvailable is YES return instance, otherwise return nil
@property (nonatomic, strong, readonly) WKWebView *wkWebView;
@property (nonatomic, strong, readonly) WKWebViewConfiguration *wkWebViewConfiguration;

// UIWebView
// kWebKitAvailable is NO return instance, otherwise return nil
@property (nonatomic, strong, readonly) UIWebView *webView;

+ (instancetype)webViewControllerWithURL:(NSString * _Nullable)URL;

- (instancetype)initWithURL:(NSString * _Nullable)URL;

// load
- (void)reload;
- (void)reloadFromOrigin;
- (void)stopLoading;

// navigation

@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;

- (void)goBack;
- (void)goForward;

@end

@protocol HWWebViewControllerDelegate <NSObject>

@optional

- (BOOL)webViewControllerShouldStartLoad:(HWWebViewController *)webVC request:(NSURLRequest *)request navigationType:(HWWebViewNavigationType)type;
- (void)webViewControllerDidStartLoading:(HWWebViewController *)webVC;
- (void)webViewControllerDidEndLoading:(HWWebViewController *)webVC error:(NSError *)error;
- (void)webView:(HWWebViewController *)webVC didReceiveNewTitle:(NSString *)newTitle isMainFrame:(BOOL)isMain;

@end

NS_ASSUME_NONNULL_END
