//
//  HWHTTPServer.m
//  Test
//
//  Created by Wang,Houwen on 2019/8/3.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "HWHTTPServer.h"
#import <HTTPFileResponse.h>
#import <objc/message.h>
#import <DAVConnection.h>

NSString *HWHTTPServerConnectionChangedNotification = @"HWHTTPServerConnectionChangedNotification";
typedef WebSocket * (^HWWebSocketSupplierBlock)(NSString *URI, HTTPMessage *request, GCDAsyncSocket *socket);

@interface HWHTTPConnection : HTTPConnection

@property (class, nonatomic, strong) NSMutableOrderedSet<BOOL (^)(NSString *key)> *shouldResponseBlocks;
@property (class, nonatomic, strong) NSMutableDictionary<NSString *, HWHTTPServerResponderBlock> *responderMap;

@end

@implementation HWHTTPConnection

@dynamic responderMap;
@dynamic shouldResponseBlocks;

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    __weak typeof(self) ws = self;
    __block NSObject<HTTPResponse> *res = nil;
    [self.class.responderMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, HWHTTPServerResponderBlock responder, BOOL *stopResponder) {
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

+ (NSMutableDictionary<NSString *, HWHTTPServerResponderBlock> *)responderMap {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:HWHTTPServerConnectionChangedNotification object:nil];
}

- (void)stop {
    [super stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:HWHTTPServerConnectionChangedNotification object:nil];
}

- (void)die {
    [super die];
    [[NSNotificationCenter defaultCenter] postNotificationName:HWHTTPServerConnectionChangedNotification object:nil];
}

@end

@interface HWHTTPWebSocketConnection : HTTPConnection

@property (class, nonatomic, strong) NSMutableOrderedSet<BOOL (^)(NSString *key)> *shouldSupplierWebSocketBlocks;
@property (class, nonatomic, strong) NSMutableDictionary<NSString *, HWWebSocketSupplierBlock> *webSocketSupplierMap;

@end

@implementation HWHTTPWebSocketConnection

@dynamic shouldSupplierWebSocketBlocks;
@dynamic webSocketSupplierMap;

- (WebSocket *)webSocketForURI:(NSString *)path {
    __weak typeof(self) ws = self;
    __block WebSocket *webSocket = nil;
    [self.class.webSocketSupplierMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, HWWebSocketSupplierBlock supplier, BOOL *stopResponder) {
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

+ (NSMutableDictionary<NSString *, HWWebSocketSupplierBlock> *)webSocketSupplierMap {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:HWHTTPServerConnectionChangedNotification object:nil];
}

- (void)stop {
    [super stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:HWHTTPServerConnectionChangedNotification object:nil];
}

- (void)die {
    [super die];
    [[NSNotificationCenter defaultCenter] postNotificationName:HWHTTPServerConnectionChangedNotification object:nil];
}

@end

#pragma mark - servers

@interface HWHTTPServer ()
@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, assign) UInt16 port;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) HWHTTPServerResponderBlock responder;

@end

@implementation HWHTTPServer

+ (instancetype)serverWithPort:(UInt16)port type:(NSString *)type responder:(HWHTTPServerResponderBlock)responder {
    NSAssert(responder, @"can not set a nil responder");
    
    HWHTTPServer *ser = [[self alloc] init];
    ser.responder = responder;
    ser.httpServer = [[HTTPServer alloc] init];
    ser.type = type;
    ser.port = port;

    NSString *iden = [NSString stringWithFormat:@"%p", ser];
    HWHTTPConnection.responderMap[iden] = responder;
    [HWHTTPConnection.shouldResponseBlocks addObject:^BOOL(NSString *key) {
        return [key isEqualToString:iden];
    }];
    [ser.httpServer setConnectionClass:[HWHTTPConnection class]];

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

@interface HWHTTPWebServer ()

@property (nonatomic, copy) NSString *docRoot;
@property (nonatomic, copy) HWHTTPWebServerMsgHandlerBlock msgHandler;

@end

@implementation HWHTTPWebServer

- (void)dealloc{
    
}

+ (instancetype)serverWithPort:(UInt16)port
                          type:(NSString *)type
                       docRoot:(NSString *)root
                    msgHandler:(HWHTTPWebServerMsgHandlerBlock)msgHandler {
    
    __block HWHTTPWebServer *ser = [super serverWithPort:port
                                                    type:(NSString *)type
                                               responder:^NSObject<HTTPResponse> *(HTTPMessage *request) {
        return nil;
    }];
    ser.msgHandler = msgHandler;
    ser.docRoot = [root copy];
    
    HWWebSocketSupplierBlock supplierBlock = ^WebSocket *(NSString *URI, HTTPMessage *request, GCDAsyncSocket *socket) {
        if ([URI hasPrefix:[@"/" stringByAppendingString:root.lastPathComponent]]) {
            WebSocket *ws = [[WebSocket alloc] initWithRequest:request socket:socket];
            ws.delegate = ser;
            return ws;
        } else {
            return nil;
        }
    };

    NSString *iden = [NSString stringWithFormat:@"%p", ser];
    HWHTTPWebSocketConnection.webSocketSupplierMap[iden] = supplierBlock;
    [HWHTTPWebSocketConnection.shouldSupplierWebSocketBlocks addObject:^BOOL(NSString *key) {
        return [key isEqualToString:iden];
    }];
    
    [ser.httpServer setConnectionClass:[HWHTTPWebSocketConnection class]];
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
