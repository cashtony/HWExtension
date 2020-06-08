//
//  BINetServiceBrowser.h
//  BILogUpload
//
//  Created by Wang,Houwen on 2019/11/17.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BINetServiceBrowser : NSObject

- (NSString *)searchForBrowsableDomainsWithTimeout:(NSTimeInterval)timeout
                                        willSearch:(void (^)(BINetServiceBrowser *browser))willSearch
                                     didStopSearch:(void (^)(BINetServiceBrowser *browser))didStopSearch
                                      didNotSearch:(void (^)(BINetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error))didNotSearch
                                     didFindDomain:(void (^)(BINetServiceBrowser *browser, NSString *domain, BOOL moreComing))didFindDomain
                                         didFinish:(void (^)(BINetServiceBrowser *browser))didFinish;

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
                                        didFinish:(void (^)(BINetServiceBrowser *browser))didFinish;

- (void)stop:(NSString *)taskId;
- (void)stopAll;

@end

NS_ASSUME_NONNULL_END
