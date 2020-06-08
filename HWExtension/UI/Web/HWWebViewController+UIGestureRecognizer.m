//
//  HWWebViewController+UIGestureRecognizer.m
//  HWExtension
//
//  Created by Wang,Houwen on 2018/9/5.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWWebViewController+UIGestureRecognizer.h"
#import "HWWebViewController+JavaScript.h"
#import <objc/message.h>

@implementation HWWebViewController (UIGestureRecognizer)

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

- (id<HWWebViewControllerGestureDelegate>)gestureDelegate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setGestureDelegate:(id<HWWebViewControllerGestureDelegate>)gestureDelegate {
    objc_setAssociatedObject(self, @selector(gestureDelegate), gestureDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)recognizer {
    
    CGPoint touchPoint = [recognizer locationInView:self.wkWebView];
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    
    __weak typeof(self) ws = self;
    [self evaluateJavaScript:js complete:^(id  _Nullable value, BOOL isJSValue, NSError * _Nullable error, HWWebViewController * _Nonnull webVC) {
        if (!error) {
            __strong typeof(ws) ss = ws;
            if (ss.gestureDelegate && [(NSObject *)ss.gestureDelegate respondsToSelector:@selector(webView:longPressAtImageSource:)]) {
                [ss.gestureDelegate webView:ss longPressAtImageSource:(isJSValue ? [(JSValue *)value toString] : value)];
            }
        }
    }];
}

@end
