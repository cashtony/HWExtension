//
//  FindServiceViewController.m
//  HWExtension
//
//  Created by Wang,Houwen on 2019/11/17.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "FindServiceViewController.h"
#import "HWNetServiceBrowser.h"
#import "UIBarButtonItem+Category.h"
#import "UITableView+Category.h"
#import "ServiceInfo.h"
#import "ServiceInfoViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface FindServiceViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HWNetServiceBrowser *serviceBrowser;
@property (nonatomic, strong) NSMutableOrderedSet<NSString *> *domains;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableOrderedSet<ServiceInfo *> *> *services;
@end

@implementation FindServiceViewController

- (void)dealloc {
    [_serviceBrowser stopAll];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _domains = [NSMutableOrderedSet orderedSet];
    _services = [NSMutableDictionary dictionary];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.rowHeight = 50;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _serviceBrowser = [[HWNetServiceBrowser alloc] init];

    __weak typeof(self) ws = self;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:@"🔍"
                                                                       actionHandler:^(UIBarButtonItem *item,
                                                                                       UIButton *customView) {
                                                                           [ws scanningServices];
                                                                       }];
    [self scanningServices];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)scanningServices {
    [_services removeAllObjects];

    ((UIButton *)self.navigationItem.rightBarButtonItem.customView).enabled = NO;

    __block NSInteger count = 0;

    __weak typeof(self) ws = self;
    [_serviceBrowser searchForBrowsableDomainsWithTimeout:60
        willSearch:^(HWNetServiceBrowser *browser) {
        }
        didStopSearch:^(HWNetServiceBrowser *browser) {
        }
        didNotSearch:^(HWNetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error) {
        }
        didFindDomain:^(HWNetServiceBrowser *browser, NSString *domain, BOOL moreComing) {
            [ws.domains addObject:domain];

            [browser searchForServicesOfTypes:@[ @"_livelog._tcp.", @"_livescreen._tcp.", @"_file._tcp." ]
                inDomain:domain
                timeout:60
                willSearch:^(HWNetServiceBrowser *browser) {
                }
                didStopSearch:^(HWNetServiceBrowser *browser) {
                }
                didNotSearch:^(HWNetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error) {
                }
                didFindService:^(HWNetServiceBrowser *browser, NSNetService *service, BOOL moreComing) {
                }
                willResolveAddress:^(HWNetServiceBrowser *browser, NSNetService *service) {
                }
                didResolveAddress:^(HWNetServiceBrowser *browser, NSNetService *service, NSString *IP) {
                    NSLog(@"解析服务成功: name: %@, type: %@, domain: %@, hostName: %@, IP: %@, port: %@",
                          service.name,
                          service.type,
                          service.domain,
                          service.hostName,
                          IP,
                          @(service.port));

                    ServiceInfo *info = [ServiceInfo new];
                    info.name = service.name;
                    info.type = service.type;
                    info.domain = service.domain;
                    info.hostName = service.hostName;
                    info.port = service.port;
                    info.IP = IP;
                    if ([service.domain isEqualToString:@"local."]) {
                        info.IP2 = [self getIpAddresses];
                    } else {
                        info.IP2 = IP;
                    }

                    NSMutableOrderedSet *set = ws.services[service.domain];
                    if (!set) {
                        set = [NSMutableOrderedSet orderedSet];
                        ws.services[service.domain] = set;
                    }
                    [set addObject:info];
                    [ws.tableView reloadData];
                }
                didNotResolve:^(HWNetServiceBrowser *browser, NSDictionary<NSString *, NSNumber *> *error) {
                }
                didFinish:^(HWNetServiceBrowser *browser) {
                    count++;
                    if (count == ws.domains.count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ((UIButton *)ws.navigationItem.rightBarButtonItem.customView).enabled = NO;
                        });
                    }
                }];
        }
        didFinish:^(HWNetServiceBrowser *browser){
        }];
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

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _services.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _services[_domains[section]].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _domains[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"
        indexPath:indexPath
        nilBlock:^__kindof UITableViewCell *(NSIndexPath *indexPath) {
            return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
        }
        initBlock:^(__kindof UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.textLabel.numberOfLines = 0;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }];

    ServiceInfo *info = _services[_domains[indexPath.section]][indexPath.row];
    cell.textLabel.text = [info.hostName stringByReplacingOccurrencesOfString:info.domain withString:@""];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ServiceInfoViewController *vc = [[ServiceInfoViewController alloc] init];
    vc.info = _services[_domains[indexPath.section]][indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
