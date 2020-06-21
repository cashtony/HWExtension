//
//  HWSysNotificationCenter.m
//  HWExtension
//
//  Created by Wang,Houwen on 2019/10/17.
//  Copyright © 2019 houwen.wang. All rights reserved.
//

#import "HWSysNotificationCenter.h"
#import <CoreFoundation/CFNotificationCenter.h>
#import <objc/message.h>

@implementation HWSysNotificationCenter

+ (void)addObserver:(id)observer
               name:(NSString *)name
           callBack:(void (^)(NSString *name))callBack {
    NSString *copyName = [name copy];
    void (^block)(CFNotificationCenterRef center,
                  void *observer,
                  CFNotificationName name,
                  const void *object,
                  CFDictionaryRef userInfo) = ^(CFNotificationCenterRef center,
                                                void *observer,
                                                CFNotificationName name,
                                                const void *object,
                                                CFDictionaryRef userInfo) {
        !callBack ?: callBack(copyName);
    };

    IMP imp = imp_implementationWithBlock(block);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(observer),
                                    (CFNotificationCallback)imp,
                                    (__bridge CFStringRef)name,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

+ (void)removeObserver:(id)observer name:(NSString *)name {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                       (__bridge const void *)(observer),
                                       (__bridge CFStringRef)name,
                                       NULL);
}

+ (void)removeEveryObserver:(id)observer {
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                            (__bridge const void *)(observer));
}

+ (void)postNotificationName:(NSNotificationName)aName
                      object:(nullable id)anObject
                    userInfo:(nullable NSDictionary *)aUserInfo {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         (__bridge CFStringRef)aName,
                                         (__bridge const void *)(anObject),
                                         (__bridge CFDictionaryRef _Nullable)aUserInfo,
                                         YES);
}

@end
