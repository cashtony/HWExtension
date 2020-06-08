//
//  HWHTTPServerManager.m
//  Test
//
//  Created by Wang,Houwen on 2019/8/4.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "HWHTTPServerManager.h"

@interface HWHTTPServerManager ()

@property (nonatomic, strong) NSMutableOrderedSet <HWHTTPServer *>*servers_innser;

@end

@implementation HWHTTPServerManager

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    static HWHTTPServerManager *m = nil;
    dispatch_once(&onceToken, ^{
        m = [HWHTTPServerManager new];
        m.servers_innser = [NSMutableOrderedSet orderedSet];
    });
    return m;
}

- (void)addServer:(HWHTTPServer *)server
{
    if (server)
    {
        [_servers_innser addObject:server];
    }
}

- (void)removeServer:(HWHTTPServer *)server
{
    if (server)
    {
        [_servers_innser removeObject:server];
    }
}

- (NSOrderedSet <HWHTTPServer *>*)servers
{
    return [_servers_innser copy];
}

@end
