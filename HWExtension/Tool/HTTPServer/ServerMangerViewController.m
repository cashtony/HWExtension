//
//  ServerMangerViewController.m
//  Test
//
//  Created by Wang,Houwen on 2019/8/4.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "ServerMangerViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "HWHTTPServerManager.h"
#import <GCDAsyncSocket.h>

@interface ManagerHeaderView : UITableViewHeaderFooterView
@property (nonatomic, strong) UISwitch *swith;
@property (nonatomic, copy) void (^swithBlock)(ManagerHeaderView *view, BOOL isOn);
@end

@implementation ManagerHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        _swith = [[UISwitch alloc] init];
        [_swith addTarget:self action:@selector(swithChaned:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_swith];
    }
    return self;
}

- (void)swithChaned:(id)sender {
    !_swithBlock ?: _swithBlock(self, _swith.isOn);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_swith sizeToFit];
    CGRect rect = _swith.frame;
    rect.origin.x = CGRectGetWidth(self.frame) - rect.size.width - 15;
    rect.origin.y = (CGRectGetHeight(self.frame) - rect.size.height) / 2.f;
    _swith.frame = rect;
}

@end

@interface ManagerCell : UITableViewCell
@end

@implementation ManagerCell
@end

@interface ServerMangerViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSOrderedSet<HWHTTPServer *> *servers;
@end

@implementation ServerMangerViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self reload];
    __weak typeof(self) ws = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:HWHTTPServerConnectionChangedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        [NSObject cancelPreviousPerformRequestsWithTarget:ws];
        [ws performSelector:@selector(reload) withObject:nil afterDelay:0.5f];
    }];
}

- (void)initUI {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerClass:[ManagerCell class] forCellReuseIdentifier:@"cellId"];
    [_tableView registerClass:[ManagerHeaderView class] forHeaderFooterViewReuseIdentifier:@"HeaderId"];
    [self.view addSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)reload {
    self.title = [NSString stringWithFormat:@"IP : %@", [self getIpAddresses]];
    _servers = [HWHTTPServerManager manager].servers;
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _servers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    HWHTTPServer *server = _servers[section];
    return [server isKindOfClass:[HWHTTPWebServer class]] ? ((HWHTTPWebServer *)server).webSockets.count : server.connections.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HWHTTPServer *server = _servers[section];
    ManagerHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HeaderId"];
    view.textLabel.text = [NSString stringWithFormat:@"%@ : %hu", server.name, server.listeningPort];
    NSInteger count = [server isKindOfClass:[HWHTTPWebServer class]] ? ((HWHTTPWebServer *)server).webSockets.count : server.connections.count;
    view.detailTextLabel.text = [NSString stringWithFormat:@"连接数 %ld", count];
    view.swith.on = server.isRunning;

    __weak typeof(self) ws = self;
    view.swithBlock = ^(ManagerHeaderView *view, BOOL isOn) {
        HWHTTPServer *server = ws.servers[section];

        if (isOn && !server.isRunning) {
            [server start:nil];
        } else if (!isOn && server.isRunning) {
            [server stop];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws reload];
        });
    };
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    HWHTTPServer *server = _servers[indexPath.section];
    if ([server isKindOfClass:[HWHTTPWebServer class]]) {
        WebSocket *ws = ((HWHTTPWebServer *)server).webSockets[indexPath.row];
        GCDAsyncSocket *socket = [ws valueForKey:@"asyncSocket"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %hu", socket.connectedHost, socket.connectedPort];
    } else if ([server isKindOfClass:[HWHTTPServer class]]) {
        HTTPConnection *cnt = server.connections[indexPath.row];
        GCDAsyncSocket *socket = [cnt valueForKey:@"asyncSocket"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %hu", socket.connectedHost, socket.connectedPort];
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

- (NSString *)getIpAddresses {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (NSString *)localIPAddress
{
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://pv.sohu.com/cityjson?ie=utf-8"];
    NSMutableString *ip = [NSMutableString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
 
    //判断返回字符串是否为所需数据
    if ([ip hasPrefix:@"var returnCitySN = "]) {
        //对字符串进行处理，然后进行json解析
        //删除字符串多余字符串
        NSRange range = NSMakeRange(0, 19);
        [ip deleteCharactersInRange:range];
        NSString * nowIp =[ip substringToIndex:ip.length-1];
        //将字符串转换成二进制进行Json解析
        NSData * data = [nowIp dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dict);
        return dict[@"cip"] ? dict[@"cip"] : @"";
    }
    return @"";
}

@end
