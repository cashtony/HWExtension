//
//  ServiceInfo.h
//  HWExtension
//
//  Created by Wang,Houwen on 2019/11/24.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, copy) NSString *IP;
@property (nonatomic, copy) NSString *IP2;
@property (nonatomic, assign) NSInteger port;

@end

NS_ASSUME_NONNULL_END
