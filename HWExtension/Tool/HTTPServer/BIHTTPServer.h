//
//  BIHTTPServer.h
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

extern NSString *BIHTTPServerConnectionChangedNotification;

typedef NSObject<HTTPResponse> *_Nullable (^BIHTTPServerResponderBlock)(HTTPMessage *request);
typedef NSString *_Nullable (^BIHTTPWebServerMsgHandlerBlock)(NSString *msg);

@interface BIHTTPServer : NSObject

@property (nonatomic, assign, readonly) UInt16 port;
@property (nonatomic, assign, readonly) UInt16 listeningPort;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) BIHTTPServerResponderBlock responder;
@property (nonatomic, copy, nullable) NSString *name;
- (NSArray<__kindof HTTPConnection *> *)connections;

+ (instancetype)serverWithPort:(UInt16)port type:(NSString *)type responder:(BIHTTPServerResponderBlock)responder;

- (BOOL)start:(NSError **)errPtr;
- (void)stop;
- (BOOL)isRunning;

@end

@interface BIHTTPWebServer : BIHTTPServer

@property (nonatomic, copy, readonly) NSString *docRoot;
@property (nonatomic, copy, readonly) BIHTTPWebServerMsgHandlerBlock msgHandler;

- (NSArray<WebSocket *> *)webSockets;

+ (instancetype)serverWithPort:(UInt16)port
                          type:(NSString *)type
                       docRoot:(NSString *)root
                    msgHandler:(BIHTTPWebServerMsgHandlerBlock)msgHandler;

- (void)sendMessageToWeb:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
