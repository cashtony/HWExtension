//
//  HWWebViewController.m
//  HWExtension
//
//  Created by houwen.wang on 16/4/25.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWWebViewController.h"

#define kErrorHtmlString (@"<!DOCTYPE html> <html> <head> <meta charset=\"UTF-8\"> <title></title> </head> <body> </body></html>")

@interface NSHTTPCookie (NSDictionary)
@end

@implementation NSHTTPCookie (NSDictionary)

+ (NSArray *)cookiesWithDictionary:(NSDictionary <NSString *, id>*)dictionary forURL:(NSURL *)URL {
    __block NSMutableArray *arr = [NSMutableArray array];
    if (dictionary) {
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSArray <NSHTTPCookie *>*cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:@{@"Set-Cookie" : [NSString stringWithFormat:@"%@=%@", key, obj]} forURL:URL ? URL : @"".hw_URL];
            [arr addObject:cookies.firstObject];
        }];
    }
    return arr;
}

+ (NSString *)cookieScriptWithDictionary:(NSDictionary <NSString *, id>*)dictionary {
    if (dictionary) {
        __block NSMutableString *script = [NSMutableString string];
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [script appendString:[NSString stringWithFormat:@"document.cookie = \"%@=%@\";", key, obj]];
        }];
        return [script copy];
    }
    return @"";
}

@end

@interface HWWebViewController ()

@property (nonatomic, copy) HWWebViewLoadStatusBlock loadStatusBlock;

// WKWebView
@property (nonatomic, strong) WKWebViewConfiguration *wkWebViewConfiguration;
@property (nonatomic, strong) WKWebView *wkWebView;

// UIWebView
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) UIView *badNetworkView;           //
@property (nonatomic, strong) UILabel *errorDescriptionLabel;   //
@property (nonatomic, strong) UIButton *reloadBtn;              //
@property (nonatomic, strong) UIImageView *badNetworkImage;     //

@end

@implementation HWWebViewController

#pragma mark - initialize

- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

+ (instancetype)webViewControllerWithUrl:(NSString * _Nullable)url identifier:(NSString * _Nullable)identifier loadStatus:(HWWebViewLoadStatusBlock _Nullable)loadStatus {
    return [[self alloc] initWithUrl:url identifier:identifier loadStatus:loadStatus];
}

- (instancetype)initWithUrl:(NSString * _Nullable)url identifier:(NSString * _Nullable)identifier loadStatus:(HWWebViewLoadStatusBlock _Nullable)loadStatus {
    if (self = [self init]) {
        self.identifier = identifier ? [identifier copy] : nil;
        self.loadStatusBlock = loadStatus ? [loadStatus copy] : nil;
        self.url = url;
    }
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadStatusCallBackWithStatus:HWWebViewLoadStatusUnLoad error:nil];
}

- (void)initUI {    
    if (kWebKitAvailable) {
        if (self.wkWebView.superview == nil) {
            [self.view addSubview:self.wkWebView];
        }
    } else {
        if (self.webView.superview == nil) {
            [self.view addSubview:self.webView];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIView *webView = kWebKitAvailable ? self.wkWebView : self.webView;
    webView.frame = self.view.bounds;
}

- (void)dealloc {
}

#pragma mark - public api

#pragma mark - load

- (void)reload {
    if (kWebKitAvailable) {
        [self.wkWebView reload];
    } else {
        [self.webView reload];
    }
}

- (void)reloadFromOrigin {
    if (kWebKitAvailable) {
        [self.wkWebView reloadFromOrigin];
    } else {
        [self.webView reload];
    }
}

- (void)stopLoading {
    if (kWebKitAvailable) {
        [self.wkWebView stopLoading];
    } else {
        [self.webView stopLoading];
    }
}

#pragma mark - setter

- (void)setUrl:(NSString *)url {
    
    _url = url ? [url copy] : nil;
    
    if (url && url.length) {
        
        NSString *timeStamp = @"timeStamp_t=";
        
        NSString *urlString = [url copy];
        
        if ([urlString rangeOfString:timeStamp].location == NSNotFound) {
            if (![urlString containsString:@"?"])
                urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?%@%@", timeStamp, @([[NSDate date] timeIntervalSince1970])]] ;
            else
                urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&%@%@", timeStamp, @([[NSDate date] timeIntervalSince1970])]];
        }
        
        NSURL *url_t = [urlString hw_URL];
        [self loadRequest:[NSMutableURLRequest requestWithURL:url_t cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30]];
    } else {
        [self loadRequest:[NSMutableURLRequest requestWithURL:[@"" hw_URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30]];
    }
}

- (void)setHtmlString:(NSString *)htmlString {
    _htmlString = htmlString;
    [self loadHTMLStringWithHTMLString:htmlString];
}

#pragma mark - WKNavigationDelegate & WKUIDelegate

//  加载状态回调

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self loadStatusCallBackWithStatus:HWWebViewLoadStatusLoading error:nil];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self handleWebViewDidEndLoad:webView error:nil];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error {
    [self handleWebViewDidEndLoad:webView error:error];
}

//  页面跳转代理方法

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    SEL selector = @selector(webViewControllerShouldStartLoad:request:navigationType:);
    if (self.delegate &&[self.delegate respondsToSelector:selector]) {
        NSDictionary <NSNumber *, NSNumber *>*typeMap = @{@(WKNavigationTypeLinkActivated) : @(HWWebViewNavigationTypeLinkClicked),
                                                          @(WKNavigationTypeFormSubmitted) : @(HWWebViewNavigationTypeFormSubmitted),
                                                          @(WKNavigationTypeBackForward) : @(HWWebViewNavigationTypeBackForward),
                                                          @(WKNavigationTypeReload) : @(HWWebViewNavigationTypeReload),
                                                          @(WKNavigationTypeFormResubmitted) : @(HWWebViewNavigationTypeFormResubmitted),
                                                          @(WKNavigationTypeOther) : @(HWWebViewNavigationTypeOther)};
        
        BOOL flg = [self.delegate webViewControllerShouldStartLoad:self request:navigationAction.request
                                                    navigationType:typeMap[@(navigationAction.navigationType)].integerValue];
        performBlock(decisionHandler, flg ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
    } else {
        performBlock(decisionHandler, WKNavigationActionPolicyAllow);
    }
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    performBlock(decisionHandler, WKNavigationResponsePolicyAllow);
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame complete:(void (^)(void))complete {
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame complete:(void (^)(BOOL))complete {
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame complete:(void (^)(NSString * _Nullable))complete {
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self loadStatusCallBackWithStatus:HWWebViewLoadStatusLoading error:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self handleWebViewDidEndLoad:webView error:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self handleWebViewDidEndLoad:webView error:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    SEL selector = @selector(webViewControllerShouldStartLoad:request:navigationType:);
    if (self.delegate &&[self.delegate respondsToSelector:selector]) {
        NSDictionary <NSNumber *, NSNumber *>*typeMap = @{@(UIWebViewNavigationTypeLinkClicked) : @(HWWebViewNavigationTypeLinkClicked),
                                                          @(UIWebViewNavigationTypeFormSubmitted) : @(HWWebViewNavigationTypeFormSubmitted),
                                                          @(UIWebViewNavigationTypeBackForward) : @(HWWebViewNavigationTypeBackForward),
                                                          @(UIWebViewNavigationTypeReload) : @(HWWebViewNavigationTypeReload),
                                                          @(UIWebViewNavigationTypeFormResubmitted) : @(HWWebViewNavigationTypeFormResubmitted),
                                                          @(UIWebViewNavigationTypeOther) : @(HWWebViewNavigationTypeOther)};
        
        return [self.delegate webViewControllerShouldStartLoad:self request:request navigationType:typeMap[@(navigationType)].integerValue];
    }
    return YES;
}

#pragma mark - HWUIWebViewHookDelegate

- (void)webView:(UIWebView *)webview didReceiveNewTitle:(NSString *)newTitle isMainFrame:(BOOL)isMainFrame {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didReceiveNewTitle:isMainFrame:)]) {
        [self.delegate webView:self didReceiveNewTitle:newTitle isMainFrame:isMainFrame];
    }
}

- (void)webView:(UIWebView *)webview javaScriptContextDidChanged:(JSContext *)newJSContext isMainFrame:(BOOL)isMainFrame {
}

#pragma mark - private methods

// 加载 request
- (void)loadRequest:(NSMutableURLRequest *)request {
    [self stopLoading];
    
    if (kWebKitAvailable) {
        [self.wkWebView loadRequest:request];
    } else {
        [self.webView loadRequest:request];
    }
}

- (void)loadHTMLStringWithHTMLString:(NSString *)htmlString {
    
    [self stopLoading];
    
    if (kWebKitAvailable){
        [self.wkWebView loadHTMLString:htmlString baseURL:nil];
    } else{
        [self.webView loadHTMLString:htmlString baseURL:nil];
    }
}

// 加载状态回调
- (void)loadStatusCallBackWithStatus:(HWWebViewLoadStatus)status error:(NSError *)err {
    
    performBlock(self.loadStatusBlock, self, self.identifier, status, err);
    
    if (status == HWWebViewLoadStatusLoading) {
        performSelector(self.delegate, @selector(webViewControllerDidStartLoading:), self);
    } else if (status == HWWebViewLoadStatusSuccess) {
        performSelector(self.delegate, @selector(webViewControllerDidEndLoading:error:), self, nil);
    } else if (status == HWWebViewLoadStatusFailed) {
        performSelector(self.delegate, @selector(webViewControllerDidEndLoading:error:), self, err);
    }
}

- (void)handleWebViewDidEndLoad:(UIView *)webView error:(NSError *)error {
    
    // 错误
    if (error) {
        
        // 请求被取消
        if (error.code == NSURLErrorCancelled) {
            return;
        }
        
        BOOL canShowBadNetworkView = [[error.userInfo[NSURLErrorFailingURLStringErrorKey] stringByReplacingOccurrencesOfString:@"/" withString:@""] containsString:[self.url stringByReplacingOccurrencesOfString:@"/" withString:@""]];
        
        if (canShowBadNetworkView) {
            NSAttributedString *errMsg = [@"页面获取失败\n请稍后重试" attributedStringWithColor:[UIColor grayColor] font:[UIFont systemFontOfSize:13]];
            
            if (error.code >= 300 || error.code < 200) {
                
                if (error.code == NSURLErrorNotConnectedToInternet) {
                    errMsg = [@"当前网络不可用\n请检查您的网络设置" attributedStringWithColor:[UIColor grayColor] font:[UIFont systemFontOfSize:13]];
                }
            }
            
            if (!self.badNetworkView.superview) {
                self.htmlString = kErrorHtmlString;
                [webView addSubview:[self badNetworkViewWithErrorMessage:errMsg]];
            }
        }
        
        [self loadStatusCallBackWithStatus:HWWebViewLoadStatusFailed error:error];
    } else {
        
        if (self.badNetworkView.superview && ![self.htmlString isEqualToString:kErrorHtmlString]) {
            [self.badNetworkView removeFromSuperview];
        }
        
        if ([self.htmlString isEqualToString:kErrorHtmlString]) {
            _htmlString = nil;
        }
        
        [self loadStatusCallBackWithStatus:HWWebViewLoadStatusSuccess error:error];
    }
}

#pragma mark - other

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return YES;
}

#pragma mark - lazy load

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.wkWebViewConfiguration];
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        _wkWebView.backgroundColor = [UIColor whiteColor];
        
        __weak typeof(self) ws = self;
        [_wkWebView observeValueForKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil changeBlock:^(NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
            __strong typeof(ws) ss = ws;
            if (ss.delegate && [self.delegate respondsToSelector:@selector(webView:didReceiveNewTitle:isMainFrame:)]) {
                [ss.delegate webView:ss didReceiveNewTitle:change[NSKeyValueChangeNewKey] isMainFrame:YES];
            }
        }];
    }
    return _wkWebView;
}

- (WKWebViewConfiguration *)wkWebViewConfiguration {
    if (!_wkWebViewConfiguration) {
        _wkWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
        
        if (@available(iOS 10.0, *)) {
            _wkWebViewConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
            _wkWebViewConfiguration.dataDetectorTypes = WKDataDetectorTypePhoneNumber | WKDataDetectorTypeLink;
        }
    }
    return _wkWebViewConfiguration;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.delegate = self;
        _webView.hookDelegate = self;
        _webView.dataDetectorTypes = UIDataDetectorTypeAll;
        _webView.scalesPageToFit = YES;
        _webView.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
        _webView.backgroundColor = [UIColor whiteColor];
    }
    return _webView;
}

- (UIView *)badNetworkView {
    if (!_badNetworkView) {
        _badNetworkView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        self.badNetworkImage.centerX = _badNetworkView.width / 2.0f;
        self.badNetworkImage.centerY = _badNetworkView.height / 2.0f;
        [_badNetworkView addSubview:self.badNetworkImage];
        
        [self.badNetworkImage addSubview:self.errorDescriptionLabel];
        [self.badNetworkImage addSubview:self.reloadBtn];
    }
    return _badNetworkView;
}

- (UIView *)badNetworkViewWithErrorMessage:(NSAttributedString *)message {
    self.errorDescriptionLabel.attributedText = message;
    self.errorDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self.errorDescriptionLabel sizeToFit];
    self.errorDescriptionLabel.top = (self.badNetworkImage.height - self.reloadBtn.height - 15.0f) / 2.0f;
    self.errorDescriptionLabel.centerX = self.badNetworkImage.width / 2.0;
    
    self.reloadBtn.top = self.errorDescriptionLabel.bottom + 15;
    self.reloadBtn.centerX = self.badNetworkImage.width / 2.0;
    
    return self.badNetworkView;
}

- (UIImageView *)badNetworkImage {
    if (!_badNetworkImage) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"bad_network@2x" ofType:@"png"];
        _badNetworkImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
        _badNetworkImage.size = [_badNetworkImage aspectScaleToFitSize:CGSizeMake(self.view.width * 0.6, self.view.height * 0.6)];
        _badNetworkImage.userInteractionEnabled = YES;
    }
    return _badNetworkImage;
}

- (UILabel *)errorDescriptionLabel {
    if (!_errorDescriptionLabel) {
        _errorDescriptionLabel = [[UILabel alloc] init];
        _errorDescriptionLabel.font = [UIFont systemFontOfSize:17];
        _errorDescriptionLabel.textColor = [UIColor grayColor];
        _errorDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        _errorDescriptionLabel.numberOfLines = 0;
    }
    return _errorDescriptionLabel;
}

- (UIButton *)reloadBtn {
    if (!_reloadBtn) {
        _reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _reloadBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_reloadBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [_reloadBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_reloadBtn sizeToFit];
        [_reloadBtn addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _reloadBtn;
}

@end

#pragma mark - Cookie

@implementation HWWebViewController (LocalCookie)

NSMutableDictionary <NSString *, NSString *>*globalCookies() {
    static NSMutableDictionary *globalCookies = nil;
    if (globalCookies == nil) {
        globalCookies = [NSMutableDictionary dictionary];
    }
    return globalCookies;
}

+ (void)load {
    [self exchangeImplementations:@selector(loadRequest:) otherMethod:@selector(_cookie_loadRequest:) isInstance:YES];
}

- (void)setCookies:(NSMutableDictionary<NSString *,NSString *> *)cookies {
    objc_setAssociatedObject(self, @selector(cookies), cookies, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSMutableDictionary<NSString *,NSString *> *)cookies {
    NSMutableDictionary *cookies = objc_getAssociatedObject(self, _cmd);
    if (cookies == nil) {
        cookies = [NSMutableDictionary dictionary];
        [self setCookies:cookies];
    }
    return cookies;
}

- (void)_cookie_loadRequest:(NSMutableURLRequest *)request {
    [self prepareLocalCookies];
    [self _cookie_loadRequest:request];
}

//  准备本地cookie, URL loading system会自动为NSURLRequest发送合适的存储cookie
- (void)prepareLocalCookies {
    
    NSMutableDictionary *cookiesDic = [[NSMutableDictionary alloc] initWithDictionary:self.cookies copyItems:YES];
    [cookiesDic addEntriesFromDictionary:globalCookies()];
    
    if (kWebKitAvailable) {
        WKUserContentController* userContentController = self.wkWebViewConfiguration.userContentController;
        if (userContentController) {
            WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:[NSHTTPCookie cookieScriptWithDictionary:cookiesDic] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [userContentController addUserScript:cookieScript];
        }
    } else {
        NSURL *url = self.url.hw_URL;
        NSArray <NSHTTPCookie *>*cookies = [NSHTTPCookie cookiesWithDictionary:cookiesDic forURL:url];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:nil];
    }
}

+ (void)addGlobalCookies:(NSDictionary <NSString *, NSString *>*)cookies {
    if (cookies && cookies.count) {
        [globalCookies() addEntriesFromDictionary:cookies];
    }
}

+ (void)setGlobalCookie:(NSString *)cookie forName:(NSString *)name {
    if (name) {
        if (cookie) {
            [globalCookies() setObject:cookie forKey:name];
        } else {
            [globalCookies() removeObjectForKey:name];
        }
    }
}

+ (void)removeAllGlobalCookies {
    [globalCookies() removeAllObjects];
}

- (void)addCookies:(NSDictionary <NSString *, NSString *>*)cookies {
    if (cookies == nil || cookies.count == 0) return;
    [self.cookies setValuesForKeysWithDictionary:cookies];
}

- (void)setCookie:(NSString *)cookie forName:(NSString *)name {
    if (name) {
        if (cookie) {
            [self.cookies setObject:cookie forKey:name];
        } else {
            [self.cookies removeObjectForKey:name];
        }
    }
}

- (void)removeAllCookies {
    [self.cookies removeAllObjects];
}

@end

#pragma mark - JavaScript

@implementation HWWebViewController (JavaScript)

// 注入JS 脚本
- (void)evaluateJavaScript:(NSString *)jsString complete:(void (^ _Nullable)(id _Nullable value, BOOL isJSValue, NSError * _Nullable error, HWWebViewController *webVC))complete {
    
    __weak typeof(self) ws = self;
    
    if (kWebKitAvailable) {
        
        [self.wkWebView evaluateScript:jsString complete:^(id _Nullable value, NSError * _Nullable error) {
            __strong typeof(ws) ss = ws;
            performBlock(complete, value, NO, error, ss);
        }];
        
    } else {
        
        [self.webView evaluateScript:jsString withSourceURL:nil complete:^(JSValue * _Nullable value, NSError * _Nullable error) {
            __strong typeof(ws) ss = ws;
            performBlock(complete, value, YES, error, ss);
        }];
    }
}

// OC调用JS方法
- (void)callJSFunction:(NSString * __nonnull)functionName arguments:(NSArray *_Nullable)arguments complete:(void (^ _Nullable)(id _Nullable value, BOOL isJSValue, NSError * _Nullable error, HWWebViewController *webVC))complete {
    
    __weak typeof(self) weakSelf = self;
    
    if (kWebKitAvailable) {
        [self.wkWebView callJSFunction:functionName arguments:arguments complete:^(id  _Nullable value, NSError * _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            performBlock(complete, value, NO, error, strongSelf);
        }];
    } else {
        [self.webView callJSFunction:functionName arguments:arguments complete:^(JSValue * _Nullable value, NSError * _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            performBlock(complete, value, YES, error, strongSelf);
        }];
    }
}

- (void)bodyTextSizeScaling:(double)scaling complete:(void (^ _Nullable)(id _Nullable value, BOOL isJSValue, NSError * _Nullable error, HWWebViewController *webVC))complete {
    NSString *js = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@%@'" , @(scaling * 100.0), @"%"];
    [self evaluateJavaScript:js complete:complete];
}

@end

#pragma mark - LongPressSavaImageSupport

@implementation HWWebViewController (LongPressSavaImageSupport)

- (UILongPressGestureRecognizer *)longPressGesture {
    UILongPressGestureRecognizer *ges = objc_getAssociatedObject(self, _cmd);
    if (ges == nil) {
        ges = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self setLongPressGesture:ges];
    }
    return ges;
}

- (void)setLongPressGesture:(UILongPressGestureRecognizer * _Nonnull)longPressGesture {
    objc_setAssociatedObject(self, @selector(longPressGesture), longPressGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)supportLongPressSavaImage {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSupportLongPressSavaImage:(BOOL)supportLongPressSavaImage {
    
    if (self.supportLongPressSavaImage != supportLongPressSavaImage) {
        
        objc_setAssociatedObject(self, @selector(supportLongPressSavaImage), @(supportLongPressSavaImage), OBJC_ASSOCIATION_ASSIGN);
        
        UIView *webView = kWebKitAvailable ? self.wkWebView : self.webView;
        
        if (supportLongPressSavaImage) {
            [webView addGestureRecognizer:self.longPressGesture];
        } else {
            [webView removeGestureRecognizer:self.longPressGesture];
        }
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)recognizer {
    
    CGPoint touchPoint = [recognizer locationInView:self.wkWebView];
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    
    __weak typeof(self) weakSelf = self;
    [self evaluateJavaScript:js complete:^(id  _Nullable value, BOOL isJSValue, NSError * _Nullable error, HWWebViewController * _Nonnull webVC) {
        if (!error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            performSelector(strongSelf.delegate,
                            @selector(webView:longPressAtImageSource:),
                            weakSelf,
                            (isJSValue ? [(JSValue *)value toString] : value));
        }
    }];
}

@end
