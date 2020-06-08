//
//  HWHTTPServer.h
//  Test
//
//  Created by Wang,Houwen on 2019/8/3.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "HTTPServer.h"
#import <HTTPMessage.h>
#import <HTTPDataResponse.h>
#import <HTTPConnection.h>
#import <WebSocket.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *HWHTTPServerConnectionChangedNotification;

typedef NSObject<HTTPResponse> *_Nullable (^HWHTTPServerResponderBlock)(HTTPMessage *request);
typedef NSString *_Nullable (^HWHTTPWebServerMsgHandlerBlock)(NSString *msg);

@interface HWHTTPServer : NSObject

@property (nonatomic, assign, readonly) UInt16 port;
@property (nonatomic, assign, readonly) UInt16 listeningPort;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) HWHTTPServerResponderBlock responder;
@property (nonatomic, copy, nullable) NSString *name;
- (NSArray<__kindof HTTPConnection *> *)connections;

+ (instancetype)serverWithPort:(UInt16)port type:(NSString *)type responder:(HWHTTPServerResponderBlock)responder;

- (BOOL)start:(NSError **)errPtr;
- (void)stop;
- (BOOL)isRunning;

@end

@interface HWHTTPWebServer : HWHTTPServer

@property (nonatomic, copy, readonly) NSString *docRoot;
@property (nonatomic, copy, readonly) HWHTTPWebServerMsgHandlerBlock msgHandler;

- (NSArray<WebSocket *> *)webSockets;

+ (instancetype)serverWithPort:(UInt16)port
                          type:(NSString *)type
                       docRoot:(NSString *)root
                    msgHandler:(HWHTTPWebServerMsgHandlerBlock)msgHandler;

- (void)sendMessageToWeb:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
