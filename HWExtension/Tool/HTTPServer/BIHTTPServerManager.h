//
//  BIHTTPServerManager.h
//  Test
//
//  Created by Wang,Houwen on 2019/8/4.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIHTTPServer.h"

NS_ASSUME_NONNULL_BEGIN

@interface BIHTTPServerManager : NSObject

@property (nonatomic, copy, readonly) NSOrderedSet <BIHTTPServer *>*servers;

+ (instancetype)manager;

- (void)addServer:(BIHTTPServer *)server;

- (void)removeServer:(BIHTTPServer *)server;

@end

NS_ASSUME_NONNULL_END
