//
//  BIHTTPServerManager.m
//  Test
//
//  Created by Wang,Houwen on 2019/8/4.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "BIHTTPServerManager.h"

@interface BIHTTPServerManager ()

@property (nonatomic, strong) NSMutableOrderedSet <BIHTTPServer *>*servers_innser;

@end

@implementation BIHTTPServerManager

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    static BIHTTPServerManager *m = nil;
    dispatch_once(&onceToken, ^{
        m = [BIHTTPServerManager new];
        m.servers_innser = [NSMutableOrderedSet orderedSet];
    });
    return m;
}

- (void)addServer:(BIHTTPServer *)server
{
    if (server)
    {
        [_servers_innser addObject:server];
    }
}

- (void)removeServer:(BIHTTPServer *)server
{
    if (server)
    {
        [_servers_innser removeObject:server];
    }
}

- (NSOrderedSet <BIHTTPServer *>*)servers
{
    return [_servers_innser copy];
}

@end
