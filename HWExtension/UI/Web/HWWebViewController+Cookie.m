//
//  HWWebViewController+Cookie.m
//  HWExtension
//
//  Created by Wang,Houwen on 2018/9/5.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWWebViewController+Cookie.h"
#import "NSObject+Category.h"
#import "NSString+Category.h"
#import "UIWebView+Category.h"
#import "WKWebView+Category.h"

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

// cookies
@property (nonatomic, strong) NSMutableDictionary *cookies;

@end

@implementation HWWebViewController (Cookie)

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
        NSURL *URL = self.URLString.hw_URL;
        NSArray <NSHTTPCookie *>*cookies = [NSHTTPCookie cookiesWithDictionary:cookiesDic forURL:URL];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:URL mainDocumentURL:nil];
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

#pragma mark - rumtime cookie support

- (void)getCookiesWithComplete:(void(^_Nullable)(NSDictionary <NSString *, NSString *>*cookies))complete {
    if (kWebKitAvailable) {
        [self.wkWebView getCookiesWithComplete:complete];
    } else {
        [self.webView getCookiesWithComplete:complete];
    }
}

- (void)getCookieForName:(NSString *)name complete:(void(^_Nullable)(NSString *cookie))complete {
    if (kWebKitAvailable) {
        [self.wkWebView getCookieForName:name complete:complete];
    } else {
        [self.webView getCookieForName:name complete:complete];
    }
}

- (void)setCookieForName:(NSString *)name value:(NSString *)value validSeconds:(NSInteger)validSeconds complete:(void(^_Nullable)(void))complete {
    if (kWebKitAvailable) {
        [self.wkWebView setCookieForName:name value:value validSeconds:validSeconds complete:complete];
    } else {
        [self.webView setCookieForName:name value:value validSeconds:validSeconds complete:complete];
    }
}

- (void)deleteCookieForName:(NSString *)name complete:(void(^_Nullable)(void))complete {
    if (kWebKitAvailable) {
        [self.wkWebView deleteCookieForName:name complete:complete];
    } else {
        [self.webView deleteCookieForName:name complete:complete];
    }
}

- (void)deleteAllCookiesWithComplete:(void(^_Nullable)(void))complete {
    if (kWebKitAvailable) {
        [self.wkWebView deleteAllCookiesWithComplete:complete];
    } else {
        [self.webView deleteAllCookiesWithComplete:complete];
    }
}

@end
