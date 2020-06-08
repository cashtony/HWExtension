//
//  HWNetServiceBrowser.h
//  HWExtension
//
//  Created by Wang,Houwen on 2019/11/17.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWNetServiceBrowser : NSObject

- (NSString *)searchForBrowsableDomainsWithTimeout:(NSTimeInterval)timeout
                                        willSearch:(void (^)(HWNetServiceBrowser *browser))willSearch
                                     didStopSearch:(void (^)(HWNetServiceBrowser *browser))didStopSearch
                                      didNotSearch:(void (^)(HWNetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error))didNotSearch
                                     didFindDomain:(void (^)(HWNetServiceBrowser *browser, NSString *domain, BOOL moreComing))didFindDomain
                                         didFinish:(void (^)(HWNetServiceBrowser *browser))didFinish;

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
                                        didFinish:(void (^)(HWNetServiceBrowser *browser))didFinish;

- (void)stop:(NSString *)taskId;
- (void)stopAll;

@end

NS_ASSUME_NONNULL_END
