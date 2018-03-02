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
#import <JavaScriptCore/JavaScriptCore.h>
#import "HWCategorys.h"

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

@interface HWWebViewController : UIViewController <WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate, HWUIWebViewHookDelegate>

+ (instancetype)webViewControllerWithUrl:(NSString * _Nullable)url identifier:(NSString * _Nullable)identifier loadStatus:(HWWebViewLoadStatusBlock _Nullable)loadStatus;

- (instancetype)initWithUrl:(NSString * _Nullable)url identifier:(NSString * _Nullable)identifier loadStatus:(HWWebViewLoadStatusBlock _Nullable)loadStatus;

@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, copy, nullable) NSString *htmlString;
@property (nonatomic, copy, nullable) NSString *identifier;  // 用于唯一标识打开的webview，需要区分回调中的webview对象时使用

@property (nonatomic, weak) id <HWWebViewControllerDelegate> delegate;  // delegate

// WKWebView
@property (nonatomic, strong, readonly) WKWebViewConfiguration *wkWebViewConfiguration;
@property (nonatomic, strong, readonly) WKWebView *wkWebView;   // 使用宏 kWebKitAvailable 判断是否可用

// UIWebView
@property (nonatomic, strong, readonly) UIWebView *webView;     // 使用宏 kWebKitAvailable 判断是否可用

// 刷新
- (void)reload;
- (void)reloadFromOrigin;
- (void)stopLoading;

@end

@interface HWWebViewController (LocalCookie)

// 添加全局 cookies
+ (void)addGlobalCookies:(NSDictionary <NSString *, NSString *>*)cookies;

// 修改全局 cookie, if not exist, add
+ (void)setGlobalCookie:(NSString *)cookie forName:(NSString *)name;

// 删除全局cookies
+ (void)removeAllGlobalCookies;

// 添加 cookies
- (void)addCookies:(NSDictionary <NSString *, NSString *>*)cookies;

// 修改 cookie, if not exist, add
- (void)setCookie:(NSString *)cookie forName:(NSString *)name;

// 删除所有cookie, 全局 cookie 下一次还会被加载
- (void)removeAllCookies;

@end

@interface HWWebViewController (JavaScript)

// 注入JS 脚本
- (void)evaluateJavaScript:(NSString *)jsString complete:(void (^ _Nullable)(id _Nullable value, BOOL isJSValue, NSError * _Nullable error, HWWebViewController *webVC))complete;

// OC调用JS方法(直接使用方法名，不需要在方法名后加括号)
- (void)callJSFunction:(NSString * __nonnull)functionName arguments:(NSArray *_Nullable)arguments complete:(void (^ _Nullable)(id _Nullable value, BOOL isJSValue, NSError * _Nullable error, HWWebViewController *webVC))complete;

// body 字体缩放
- (void)bodyTextSizeScaling:(double)scaling complete:(void (^ _Nullable)(id _Nullable value, BOOL isJSValue, NSError * _Nullable error, HWWebViewController *webVC))complete;

@end

@interface HWWebViewController (LongPressSavaImageSupport)

@property (nonatomic, assign) BOOL supportLongPressSavaImage;                              // default is NO
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture;    //

@end

@protocol HWWebViewControllerDelegate <NSObject>

@optional

- (BOOL)webViewControllerShouldStartLoad:(HWWebViewController *)webVC
                                 request:(NSURLRequest *)request
                          navigationType:(HWWebViewNavigationType)navType;

- (void)webViewControllerDidStartLoading:(HWWebViewController *)webVC;
- (void)webViewControllerDidEndLoading:(HWWebViewController *)webVC error:(NSError *)error;
- (void)webView:(HWWebViewController *)webVC didReceiveNewTitle:(NSString *)newTitle isMainFrame:(BOOL)isMainFrame;
- (void)webView:(HWWebViewController *)webVC longPressAtImageSource:(NSString *)imageURL;

@end

NS_ASSUME_NONNULL_END
