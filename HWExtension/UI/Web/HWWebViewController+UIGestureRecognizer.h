//
//  HWWebViewController+UIGestureRecognizer.h
//  HWExtension
//
//  Created by Wang,Houwen on 2018/9/5.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWWebViewController.h"

@protocol HWWebViewControllerGestureDelegate

@optional

- (void)webView:(HWWebViewController *)webVC longPressAtImageSource:(NSString *)imageURL;

@end

@interface HWWebViewController (UIGestureRecognizer)

@property (nonatomic, weak) id <HWWebViewControllerGestureDelegate> gestureDelegate;

@property (nonatomic, assign) BOOL supportLongPressSavaImage;                              // default is NO
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture;    //

@end
