//
//  BINetServiceBrowser.m
//  BILogUpload
//
//  Created by Wang,Houwen on 2019/11/17.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "BINetServiceBrowser.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>

@interface BIScanningHandler : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, strong) NSNetServiceBrowser *browser;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, copy) void (^willSearch)(BIScanningHandler *handler);
@property (nonatomic, copy) void (^didStopSearch)(BIScanningHandler *handler);
@property (nonatomic, copy) void (^didNotSearch)(BIScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error);

@property (nonatomic, copy) void (^didFindDomain)(BIScanningHandler *handler, NSString *domain, BOOL moreComing);
@property (nonatomic, copy) void (^didFindService)(BIScanningHandler *handler, NSNetService *service, BOOL moreComing);
@property (nonatomic, copy) void (^didRemoveDomain)(BIScanningHandler *handler, NSString *domain, BOOL moreComing);
@property (nonatomic, copy) void (^didRemoveService)(BIScanningHandler *handler, NSNetService *service, BOOL moreComing);

@property (nonatomic, copy) void (^willResolveAddress)(BIScanningHandler *handler, NSNetService *service);
@property (nonatomic, copy) void (^didResolveAddress)(BIScanningHandler *handler, NSNetService *service);
@property (nonatomic, copy) void (^didNotResolve)(BIScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error);

@property (nonatomic, copy) void (^didFinish)(BIScanningHandler *handler);

@end

@implementation BIScanningHandler

- (void)servicesScanning {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:_timeout]];
    [_browser scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _browser.includesPeerToPeer = YES;
    [_browser searchForServicesOfType:_type inDomain:_domain];

    __weak typeof(self) ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ws.browser stop];
        !ws.didFinish ?: ws.didFinish(ws);
    });
}

- (void)domainScanning {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:_timeout]];
    [_browser scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _browser.includesPeerToPeer = YES;
    [_browser searchForBrowsableDomains];

    __weak typeof(self) ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ws.browser stop];
        !ws.didFinish ?: ws.didFinish(ws);
    });
}

- (void)setBrowser:(NSNetServiceBrowser *)browser {
    _browser = browser;
    _browser.delegate = self;
}

- (void)dealloc {
}

#pragma mark - delegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
    !_willSearch ?: _willSearch(self);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
    !_didStopSearch ?: _didStopSearch(self);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    !_didNotSearch ?: _didNotSearch(self, errorDict);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    !_didFindDomain ?: _didFindDomain(self, domainString, moreComing);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    [service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    service.delegate = self;
    [service resolveWithTimeout:_timeout];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:_timeout]];
    !_didFindService ?: _didFindService(self, service, moreComing);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    !_didRemoveDomain ?: _didRemoveDomain(self, domainString, moreComing);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    !_didRemoveService ?: _didRemoveService(self, service, moreComing);
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceWillResolve:(NSNetService *)sender {
    !_willResolveAddress ?: _willResolveAddress(self, sender);
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    !_didResolveAddress ?: _didResolveAddress(self, sender);
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    !_didNotResolve ?: _didNotResolve(self, errorDict);
}

- (void)netServiceDidStop:(NSNetService *)sender {
}

/* Sent to the NSNetService instance's delegate when the instance is being monitored and the instance's TXT record has been updated. The new record is contained in the data parameter.
*/
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {
}

/* Sent to a published NSNetService instance's delegate when a new connection is
 * received. Before you can communicate with the connecting client, you must -open
 * and schedule the streams. To reject a connection, just -open both streams and
 * then immediately -close them.
 
 * To enable TLS on the stream, set the various TLS settings using
 * kCFStreamPropertySSLSettings before calling -open. You must also specify
 * kCFBooleanTrue for kCFStreamSSLIsServer in the settings dictionary along with
 * a valid SecIdentityRef as the first entry of kCFStreamSSLCertificates.
 */
- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
}

@end

@interface BINetServiceBrowser ()
@property (nonatomic, strong) NSMutableSet<BIScanningHandler *> *serviceHandlers;
@property (nonatomic, strong) NSMutableSet<BIScanningHandler *> *domainHandlers;
@end

@implementation BINetServiceBrowser

- (NSString *)searchForBrowsableDomainsWithTimeout:(NSTimeInterval)timeout
                                        willSearch:(void (^)(BINetServiceBrowser *browser))willSearch
                                     didStopSearch:(void (^)(BINetServiceBrowser *browser))didStopSearch
                                      didNotSearch:(void (^)(BINetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error))didNotSearch
                                     didFindDomain:(void (^)(BINetServiceBrowser *browser, NSString *domain, BOOL moreComing))didFindDomain
                                         didFinish:(void (^)(BINetServiceBrowser *browser))didFinish {
    BIScanningHandler *handler = [BIScanningHandler new];
    __weak typeof(self) ws = self;
    handler.willSearch = ^(BIScanningHandler *handler) {
        !willSearch ?: willSearch(ws);
    };
    handler.didStopSearch = ^(BIScanningHandler *handler) {
        !didStopSearch ?: didStopSearch(ws);
    };
    handler.didNotSearch = ^(BIScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error) {
        !didNotSearch ?: didNotSearch(ws, error);
    };
    handler.didFindDomain = ^(BIScanningHandler *handler, NSString *domain, BOOL moreComing) {
        !didFindDomain ?: didFindDomain(ws, domain, moreComing);
    };
    handler.didFinish = ^(BIScanningHandler *hd) {
        [ws.domainHandlers removeObject:hd];
        !didFinish ?: didFinish(ws);
    };

    NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc] init];
    handler.browser = browser;
    handler.timeout = timeout;

    NSString *iden = [NSString stringWithFormat:@"domainScanning-%@-%p", @(self.domainHandlers.count), handler];
    [_domainHandlers addObject:handler];

    NSThread *thread = [[NSThread alloc] initWithTarget:handler selector:@selector(domainScanning) object:nil];
    thread.name = iden;
    [thread start];
    return iden;
}

- (NSArray<NSString *> *)searchForServicesOfTypes:(NSArray<NSString *> *)types
                                         inDomain:(NSString *)domain
                                          timeout:(NSTimeInterval)timeout
                                       willSearch:(void (^)(BINetServiceBrowser *browser))willSearch
                                    didStopSearch:(void (^)(BINetServiceBrowser *browser))didStopSearch
                                     didNotSearch:(void (^)(BINetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error))didNotSearch
                                   didFindService:(void (^)(BINetServiceBrowser *browser, NSNetService *service, BOOL moreComing))didFindService
                               willResolveAddress:(void (^)(BINetServiceBrowser *browser, NSNetService *service))willResolveAddress
                                didResolveAddress:(void (^)(BINetServiceBrowser *browser, NSNetService *service, NSString *IP))didResolveAddress
                                    didNotResolve:(void (^)(BINetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error))didNotResolve
                                        didFinish:(void (^)(BINetServiceBrowser *browser))didFinish {
    NSMutableArray *idens = [NSMutableArray array];
    for (NSString *type in types) {
        BIScanningHandler *handler = [BIScanningHandler new];
        __weak typeof(self) ws = self;
        handler.willSearch = ^(BIScanningHandler *handler) {
            !willSearch ?: willSearch(ws);
        };
        handler.didStopSearch = ^(BIScanningHandler *handler) {
            !didStopSearch ?: didStopSearch(ws);
        };
        handler.didNotSearch = ^(BIScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error) {
            !didNotSearch ?: didNotSearch(ws, error);
        };

        handler.didFindService = ^(BIScanningHandler *handler, NSNetService *service, BOOL moreComing) {
            !didFindService ?: didFindService(ws, service, moreComing);
        };

        handler.willResolveAddress = ^(BIScanningHandler *handler, NSNetService *service) {
            !willResolveAddress ?: willResolveAddress(ws, service);
        };
        handler.didResolveAddress = ^(BIScanningHandler *handler, NSNetService *service) {
            NSData *address = [service.addresses firstObject];
            struct sockaddr_in *socketAddress = (struct sockaddr_in *)[address bytes];
            //        NSString *hostName = [service hostName];
            //        Byte *bytes = (Byte *)[[service TXTRecordData] bytes];
            //        int8_t lenth = (int8_t)bytes[0];
            //        const void *textData = &bytes[1];
            char *ip = inet_ntoa(socketAddress->sin_addr);
            //        NSLog(@"server info: ip:%s, hostName:%@, text:%s, length:%d", ip, hostName, textData, lenth);
            !didResolveAddress ?: didResolveAddress(ws, service, [NSString stringWithUTF8String:ip]);
        };
        handler.didNotResolve = ^(BIScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error) {
            !didNotResolve ?: didNotResolve(ws, error);
        };
        handler.didFinish = ^(BIScanningHandler *hd) {
            [ws.serviceHandlers removeObject:hd];
            !didFinish ?: didFinish(ws);
        };

        NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc] init];
        handler.browser = browser;
        handler.type = type;
        handler.domain = domain;
        handler.timeout = timeout;

        NSString *iden = [NSString stringWithFormat:@"servicesScanning-%@-%p", @(self.serviceHandlers.count), handler];
        [_serviceHandlers addObject:handler];

        NSThread *thread = [[NSThread alloc] initWithTarget:handler selector:@selector(servicesScanning) object:nil];
        thread.name = iden;
        [thread start];
        [idens addObject:iden];
    }
    return [idens copy];
}

- (void)stop:(NSString *)taskId {
    __weak typeof(self) ws = self;
    NSString *iden = [taskId componentsSeparatedByString:@"-"].lastObject;
    if ([taskId hasPrefix:@"servicesScanning"]) {
        [_serviceHandlers enumerateObjectsUsingBlock:^(BIScanningHandler *obj, BOOL *stop) {
            if ([[NSString stringWithFormat:@"%p", obj] isEqualToString:iden]) {
                [obj.browser stop];
                [ws.serviceHandlers removeObject:obj];
                *stop = YES;
            }
        }];
    } else if ([taskId hasPrefix:@"domainScanning"]) {
        [_domainHandlers enumerateObjectsUsingBlock:^(BIScanningHandler *obj, BOOL *stop) {
            if ([[NSString stringWithFormat:@"%p", obj] isEqualToString:iden]) {
                [obj.browser stop];
                [ws.domainHandlers removeObject:obj];
                *stop = YES;
            }
        }];
    }
}

- (void)stopAll {
    [_serviceHandlers enumerateObjectsUsingBlock:^(BIScanningHandler *obj, BOOL *stop) {
        [obj.browser stop];
    }];
    [_serviceHandlers removeAllObjects];

    [_domainHandlers enumerateObjectsUsingBlock:^(BIScanningHandler *obj, BOOL *stop) {
        [obj.browser stop];
    }];
    [_domainHandlers removeAllObjects];
}

- (NSMutableSet<BIScanningHandler *> *)domainHandlers {
    if (!_domainHandlers) {
        _domainHandlers = [NSMutableSet set];
    }
    return _domainHandlers;
}

- (NSMutableSet<BIScanningHandler *> *)serviceHandlers {
    if (!_serviceHandlers) {
        _serviceHandlers = [NSMutableSet set];
    }
    return _serviceHandlers;
}

@end
