//
//  BIHTTPServer.m
//  Test
//
//  Created by Wang,Houwen on 2019/8/3.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "BIHTTPServer.h"
#import <HTTPFileResponse.h>
#import <objc/message.h>
#import <DAVConnection.h>

NSString *BIHTTPServerConnectionChangedNotification = @"BIHTTPServerConnectionChangedNotification";
typedef WebSocket * (^BIWebSocketSupplierBlock)(NSString *URI, HTTPMessage *request, GCDAsyncSocket *socket);

@interface BIHTTPConnection : HTTPConnection

@property (class, nonatomic, strong) NSMutableOrderedSet<BOOL (^)(NSString *key)> *shouldResponseBlocks;
@property (class, nonatomic, strong) NSMutableDictionary<NSString *, BIHTTPServerResponderBlock> *responderMap;

@end

@implementation BIHTTPConnection

@dynamic responderMap;
@dynamic shouldResponseBlocks;

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    __weak typeof(self) ws = self;
    __block NSObject<HTTPResponse> *res = nil;
    [self.class.responderMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, BIHTTPServerResponderBlock responder, BOOL *stopResponder) {
        [ws.class.shouldResponseBlocks enumerateObjectsUsingBlock:^(BOOL (^obj)(NSString *), NSUInteger idx, BOOL *stop) {
            if (obj(key)) {
                res = responder([self valueForKey:@"request"]);
                *stop = YES;
                *stopResponder = YES;
            }
        }];
    }];
    return res;
}

+ (NSMutableDictionary<NSString *, BIHTTPServerResponderBlock> *)responderMap {
    static NSMutableDictionary *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [NSMutableDictionary dictionary];
    });
    return map;
}

+ (NSMutableOrderedSet *)shouldResponseBlocks {
    static NSMutableOrderedSet *set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableOrderedSet orderedSet];
    });
    return set;
}

- (void)start {
    [super start];
    [[NSNotificationCenter defaultCenter] postNotificationName:BIHTTPServerConnectionChangedNotification object:nil];
}

- (void)stop {
    [super stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:BIHTTPServerConnectionChangedNotification object:nil];
}

- (void)die {
    [super die];
    [[NSNotificationCenter defaultCenter] postNotificationName:BIHTTPServerConnectionChangedNotification object:nil];
}

@end

@interface BIHTTPWebSocketConnection : HTTPConnection

@property (class, nonatomic, strong) NSMutableOrderedSet<BOOL (^)(NSString *key)> *shouldSupplierWebSocketBlocks;
@property (class, nonatomic, strong) NSMutableDictionary<NSString *, BIWebSocketSupplierBlock> *webSocketSupplierMap;

@end

@implementation BIHTTPWebSocketConnection

@dynamic shouldSupplierWebSocketBlocks;
@dynamic webSocketSupplierMap;

- (WebSocket *)webSocketForURI:(NSString *)path {
    __weak typeof(self) ws = self;
    __block WebSocket *webSocket = nil;
    [self.class.webSocketSupplierMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, BIWebSocketSupplierBlock supplier, BOOL *stopResponder) {
        [ws.class.shouldSupplierWebSocketBlocks enumerateObjectsUsingBlock:^(BOOL (^obj)(NSString *), NSUInteger idx, BOOL *stop) {
            if (obj(key)) {
                webSocket = supplier(path, [self valueForKey:@"request"], [self valueForKey:@"asyncSocket"]);
                *stop = YES;
                *stopResponder = YES;
            }
        }];
    }];
    return webSocket;
}

+ (NSMutableDictionary<NSString *, BIWebSocketSupplierBlock> *)webSocketSupplierMap {
    static NSMutableDictionary *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [NSMutableDictionary dictionary];
    });
    return map;
}

+ (NSMutableOrderedSet<BOOL (^)(NSString *)> *)shouldSupplierWebSocketBlocks {
    static NSMutableOrderedSet *set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableOrderedSet orderedSet];
    });
    return set;
}

- (void)start {
    [super start];
    [[NSNotificationCenter defaultCenter] postNotificationName:BIHTTPServerConnectionChangedNotification object:nil];
}

- (void)stop {
    [super stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:BIHTTPServerConnectionChangedNotification object:nil];
}

- (void)die {
    [super die];
    [[NSNotificationCenter defaultCenter] postNotificationName:BIHTTPServerConnectionChangedNotification object:nil];
}

@end

#pragma mark - servers

@interface BIHTTPServer ()
@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, assign) UInt16 port;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) BIHTTPServerResponderBlock responder;

@end

@implementation BIHTTPServer

+ (instancetype)serverWithPort:(UInt16)port type:(NSString *)type responder:(BIHTTPServerResponderBlock)responder {
    NSAssert(responder, @"can not set a nil responder");
    
    BIHTTPServer *ser = [[self alloc] init];
    ser.responder = responder;
    ser.httpServer = [[HTTPServer alloc] init];
    ser.type = type;
    ser.port = port;

    NSString *iden = [NSString stringWithFormat:@"%p", ser];
    BIHTTPConnection.responderMap[iden] = responder;
    [BIHTTPConnection.shouldResponseBlocks addObject:^BOOL(NSString *key) {
        return [key isEqualToString:iden];
    }];
    [ser.httpServer setConnectionClass:[BIHTTPConnection class]];

    return ser;
}

- (void)setPort:(UInt16)port {
    _port = port;
    _httpServer.port = port;
}

- (UInt16)listeningPort
{
    return _httpServer.listeningPort;
}

- (void)setType:(NSString *)type {
    _type = [type copy];
    _httpServer.type = type;
}

- (void)setName:(NSString *)name {
    _name = [name copy];
    _httpServer.name = name;
}

- (BOOL)start:(NSError **)errPtr {
    NSError *error = nil;
    BOOL ret = [_httpServer start:&error];
    if (ret) {
        NSLog(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
    } else {
        if (errPtr) {
            *errPtr = error;
        }
        NSLog(@"Error starting HTTP Server: %@", error);
    }
    return ret;
}

- (void)stop {
    NSLog(@"Stop HTTP Server on port %hu", [_httpServer listeningPort]);
    [_httpServer stop];
}

- (BOOL)isRunning {
    return [_httpServer isRunning];
}

- (NSArray<__kindof HTTPConnection *> *)connections {
    return [[_httpServer valueForKey:@"connections"] copy];
}

@end

@interface BIHTTPWebServer ()

@property (nonatomic, copy) NSString *docRoot;
@property (nonatomic, copy) BIHTTPWebServerMsgHandlerBlock msgHandler;

@end

@implementation BIHTTPWebServer

- (void)dealloc{
    
}

+ (instancetype)serverWithPort:(UInt16)port
                          type:(NSString *)type
                       docRoot:(NSString *)root
                    msgHandler:(BIHTTPWebServerMsgHandlerBlock)msgHandler {
    
    __block BIHTTPWebServer *ser = [super serverWithPort:port
                                                    type:(NSString *)type
                                               responder:^NSObject<HTTPResponse> *(HTTPMessage *request) {
        return nil;
    }];
    ser.msgHandler = msgHandler;
    ser.docRoot = [root copy];
    
    BIWebSocketSupplierBlock supplierBlock = ^WebSocket *(NSString *URI, HTTPMessage *request, GCDAsyncSocket *socket) {
        if ([URI hasPrefix:[@"/" stringByAppendingString:root.lastPathComponent]]) {
            WebSocket *ws = [[WebSocket alloc] initWithRequest:request socket:socket];
            ws.delegate = ser;
            return ws;
        } else {
            return nil;
        }
    };

    NSString *iden = [NSString stringWithFormat:@"%p", ser];
    BIHTTPWebSocketConnection.webSocketSupplierMap[iden] = supplierBlock;
    [BIHTTPWebSocketConnection.shouldSupplierWebSocketBlocks addObject:^BOOL(NSString *key) {
        return [key isEqualToString:iden];
    }];
    
    [ser.httpServer setConnectionClass:[BIHTTPWebSocketConnection class]];
    return ser;
}

- (void)setDocRoot:(NSString *)docRoot {
    _docRoot = [docRoot copy];
    [self.httpServer setDocumentRoot:docRoot];
}

- (void)sendMessageToWeb:(NSString *)msg {
    [[self webSockets] enumerateObjectsUsingBlock:^(WebSocket *obj, NSUInteger idx, BOOL *stop) {
        [obj sendMessage:msg];
    }];
}

- (NSArray<WebSocket *> *)webSockets {
    return [self.httpServer valueForKey:@"webSockets"];
}

#pragma mark - websocket delegate

- (void)webSocketDidOpen:(WebSocket *)ws {
}

- (void)webSocket:(WebSocket *)ws didReceiveMessage:(NSString *)msg {
    if (_msgHandler) {
        NSString *responseMsg = _msgHandler(msg);
        [self sendMessageToWeb:responseMsg];
    }
}

- (void)webSocketDidClose:(WebSocket *)ws {
}

@end
