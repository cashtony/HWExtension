//
//  HWHTTPServerManager.h
//  Test
//
//  Created by Wang,Houwen on 2019/8/4.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWHTTPServer.h"

NS_ASSUME_NONNULL_BEGIN

@interface HWHTTPServerManager : NSObject

@property (nonatomic, copy, readonly) NSOrderedSet <HWHTTPServer *>*servers;

+ (instancetype)manager;

- (void)addServer:(HWHTTPServer *)server;

- (void)removeServer:(HWHTTPServer *)server;

@end

NS_ASSUME_NONNULL_END
