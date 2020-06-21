//
//  HWSysNotificationCenter.h
//  HWExtension
//
//  Created by Wang,Houwen on 2019/10/17.
//  Copyright © 2019 houwen.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWSysNotificationCenter : NSObject

+ (void)addObserver:(id)observer
               name:(NSString *)name
           callBack:(void (^)(NSString *name))callBack;

+ (void)removeObserver:(id)observer name:(NSString *)name;
+ (void)removeEveryObserver:(id)observer;
+ (void)postNotificationName:(NSNotificationName)aName
                      object:(nullable id)anObject
                    userInfo:(nullable NSDictionary *)aUserInfo;

@end

NS_ASSUME_NONNULL_END
