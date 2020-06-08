//
//  HWNetServiceBrowser.m
//  HWExtension
//
//  Created by Wang,Houwen on 2019/11/17.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "HWNetServiceBrowser.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>

@interface HWScanningHandler : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, strong) NSNetServiceBrowser *browser;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, copy) void (^willSearch)(HWScanningHandler *handler);
@property (nonatomic, copy) void (^didStopSearch)(HWScanningHandler *handler);
@property (nonatomic, copy) void (^didNotSearch)(HWScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error);

@property (nonatomic, copy) void (^didFindDomain)(HWScanningHandler *handler, NSString *domain, BOOL moreComing);
@property (nonatomic, copy) void (^didFindService)(HWScanningHandler *handler, NSNetService *service, BOOL moreComing);
@property (nonatomic, copy) void (^didRemoveDomain)(HWScanningHandler *handler, NSString *domain, BOOL moreComing);
@property (nonatomic, copy) void (^didRemoveService)(HWScanningHandler *handler, NSNetService *service, BOOL moreComing);

@property (nonatomic, copy) void (^willResolveAddress)(HWScanningHandler *handler, NSNetService *service);
@property (nonatomic, copy) void (^didResolveAddress)(HWScanningHandler *handler, NSNetService *service);
@property (nonatomic, copy) void (^didNotResolve)(HWScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error);

@property (nonatomic, copy) void (^didFinish)(HWScanningHandler *handler);

@end

@implementation HWScanningHandler

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

@interface HWNetServiceBrowser ()
@property (nonatomic, strong) NSMutableSet<HWScanningHandler *> *serviceHandlers;
@property (nonatomic, strong) NSMutableSet<HWScanningHandler *> *domainHandlers;
@end

@implementation HWNetServiceBrowser

- (NSString *)searchForBrowsableDomainsWithTimeout:(NSTimeInterval)timeout
                                        willSearch:(void (^)(HWNetServiceBrowser *browser))willSearch
                                     didStopSearch:(void (^)(HWNetServiceBrowser *browser))didStopSearch
                                      didNotSearch:(void (^)(HWNetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error))didNotSearch
                                     didFindDomain:(void (^)(HWNetServiceBrowser *browser, NSString *domain, BOOL moreComing))didFindDomain
                                         didFinish:(void (^)(HWNetServiceBrowser *browser))didFinish {
    HWScanningHandler *handler = [HWScanningHandler new];
    __weak typeof(self) ws = self;
    handler.willSearch = ^(HWScanningHandler *handler) {
        !willSearch ?: willSearch(ws);
    };
    handler.didStopSearch = ^(HWScanningHandler *handler) {
        !didStopSearch ?: didStopSearch(ws);
    };
    handler.didNotSearch = ^(HWScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error) {
        !didNotSearch ?: didNotSearch(ws, error);
    };
    handler.didFindDomain = ^(HWScanningHandler *handler, NSString *domain, BOOL moreComing) {
        !didFindDomain ?: didFindDomain(ws, domain, moreComing);
    };
    handler.didFinish = ^(HWScanningHandler *hd) {
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
                                       willSearch:(void (^)(HWNetServiceBrowser *browser))willSearch
                                    didStopSearch:(void (^)(HWNetServiceBrowser *browser))didStopSearch
                                     didNotSearch:(void (^)(HWNetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error))didNotSearch
                                   didFindService:(void (^)(HWNetServiceBrowser *browser, NSNetService *service, BOOL moreComing))didFindService
                               willResolveAddress:(void (^)(HWNetServiceBrowser *browser, NSNetService *service))willResolveAddress
                                didResolveAddress:(void (^)(HWNetServiceBrowser *browser, NSNetService *service, NSString *IP))didResolveAddress
                                    didNotResolve:(void (^)(HWNetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error))didNotResolve
                                        didFinish:(void (^)(HWNetServiceBrowser *browser))didFinish {
    NSMutableArray *idens = [NSMutableArray array];
    for (NSString *type in types) {
        HWScanningHandler *handler = [HWScanningHandler new];
        __weak typeof(self) ws = self;
        handler.willSearch = ^(HWScanningHandler *handler) {
            !willSearch ?: willSearch(ws);
        };
        handler.didStopSearch = ^(HWScanningHandler *handler) {
            !didStopSearch ?: didStopSearch(ws);
        };
        handler.didNotSearch = ^(HWScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error) {
            !didNotSearch ?: didNotSearch(ws, error);
        };

        handler.didFindService = ^(HWScanningHandler *handler, NSNetService *service, BOOL moreComing) {
            !didFindService ?: didFindService(ws, service, moreComing);
        };

        handler.willResolveAddress = ^(HWScanningHandler *handler, NSNetService *service) {
            !willResolveAddress ?: willResolveAddress(ws, service);
        };
        handler.didResolveAddress = ^(HWScanningHandler *handler, NSNetService *service) {
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
        handler.didNotResolve = ^(HWScanningHandler *handler, NSDictionary<NSString *, NSNumber *> *error) {
            !didNotResolve ?: didNotResolve(ws, error);
        };
        handler.didFinish = ^(HWScanningHandler *hd) {
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
        [_serviceHandlers enumerateObjectsUsingBlock:^(HWScanningHandler *obj, BOOL *stop) {
            if ([[NSString stringWithFormat:@"%p", obj] isEqualToString:iden]) {
                [obj.browser stop];
                [ws.serviceHandlers removeObject:obj];
                *stop = YES;
            }
        }];
    } else if ([taskId hasPrefix:@"domainScanning"]) {
        [_domainHandlers enumerateObjectsUsingBlock:^(HWScanningHandler *obj, BOOL *stop) {
            if ([[NSString stringWithFormat:@"%p", obj] isEqualToString:iden]) {
                [obj.browser stop];
                [ws.domainHandlers removeObject:obj];
                *stop = YES;
            }
        }];
    }
}

- (void)stopAll {
    [_serviceHandlers enumerateObjectsUsingBlock:^(HWScanningHandler *obj, BOOL *stop) {
        [obj.browser stop];
    }];
    [_serviceHandlers removeAllObjects];

    [_domainHandlers enumerateObjectsUsingBlock:^(HWScanningHandler *obj, BOOL *stop) {
        [obj.browser stop];
    }];
    [_domainHandlers removeAllObjects];
}

- (NSMutableSet<HWScanningHandler *> *)domainHandlers {
    if (!_domainHandlers) {
        _domainHandlers = [NSMutableSet set];
    }
    return _domainHandlers;
}

- (NSMutableSet<HWScanningHandler *> *)serviceHandlers {
    if (!_serviceHandlers) {
        _serviceHandlers = [NSMutableSet set];
    }
    return _serviceHandlers;
}

@end
