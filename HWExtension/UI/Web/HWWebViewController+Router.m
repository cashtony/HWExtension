//
//  HWWebViewController+Router.m
//  HWExtension
//
//  Created by Wang,Houwen on 2018/9/12.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWWebViewController+Router.h"

@implementation HWWebViewController (Router)

+ (NSArray<NSString *> *)publicPropertyNames {
    return @[@"URLString", @"HTMLString", @"identifier"];
}

+ (HWRouteActionPolicy)decideRoutePolicyWithParameters:(NSDictionary<NSString *,id> *)parameters module:(NSString *)module {
    return HWRouteActionPolicyAllow;
}

@end
