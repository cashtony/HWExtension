//
//  ServiceInfoViewController.m
//  HWExtension
//
//  Created by Wang,Houwen on 2019/11/24.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "ServiceInfoViewController.h"
#import "UITableView+Category.h"
#import "UIImage+Category.h"
//#import "UIView+MBProgressHUD.h"

@interface ServiceInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *cellTitles;
@property (nonatomic, strong) NSMutableArray *cellDetail;
@property (nonatomic, strong) UIButton *gotoWebBtn;
@property (nonatomic, strong) UIButton *shareLinkBtn;

@end

@implementation ServiceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.rowHeight = 45;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    _gotoWebBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_gotoWebBtn setTitle:@"连   接" forState:UIControlStateNormal];
    [_gotoWebBtn setBackgroundImage:[UIImage imageWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
    [_gotoWebBtn setBackgroundImage:[UIImage imageWithColor:[[UIColor blueColor] colorWithAlphaComponent:0.6]] forState:UIControlStateHighlighted];
    [_gotoWebBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        bottomInset = [UIApplication sharedApplication].keyWindow.rootViewController.view.safeAreaInsets.bottom;
    }
    _gotoWebBtn.frame = CGRectMake(15, self.view.bounds.size.height - 45 - 64 - 55 - bottomInset, self.view.bounds.size.width - 30, 45);
    _gotoWebBtn.layer.cornerRadius = 5;
    _gotoWebBtn.clipsToBounds = YES;
    [self.view addSubview:_gotoWebBtn];
    [_gotoWebBtn addTarget:self action:@selector(gotoWeb:) forControlEvents:UIControlEventTouchUpInside];
    
    _shareLinkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareLinkBtn setTitle:@"复制链接" forState:UIControlStateNormal];
    [_shareLinkBtn setBackgroundImage:[UIImage imageWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
    [_shareLinkBtn setBackgroundImage:[UIImage imageWithColor:[[UIColor blueColor] colorWithAlphaComponent:0.6]] forState:UIControlStateHighlighted];
    [_shareLinkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    _shareLinkBtn.frame = CGRectMake(15, self.view.bounds.size.height - 45 - 64 - bottomInset, self.view.bounds.size.width - 30, 45);
    _shareLinkBtn.layer.cornerRadius = 5;
    _shareLinkBtn.clipsToBounds = YES;
    [self.view addSubview:_shareLinkBtn];
    [_shareLinkBtn addTarget:self action:@selector(copyLink:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)gotoWeb:(id)sender {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication]
                      openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@", _info.IP, @(_info.port)]]
                      options:@{ UIApplicationOpenURLOptionUniversalLinksOnly : @NO }
            completionHandler:^(BOOL success){

            }];
    } else {
        [[UIApplication sharedApplication]
            openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", _info.hostName, @(_info.port)]]];
    }
}

- (void)copyLink:(id)sender {
    [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"http://%@:%@", _info.IP2, @(_info.port)];
//    [self.view showToast:@"已复制" type:VSToastTypeText hideDelay:0.5f didHidden:nil];
}

- (void)setInfo:(ServiceInfo *)info {
    _info = info;
    if (!_cellTitles) {
        _cellTitles = @[ @"Name", @"Type", @"HostName", @"Domain", @"Port", @"IP" ];
        _cellDetail = [NSMutableArray array];
    }
    [_cellDetail removeAllObjects];
    [_cellDetail addObjectsFromArray:@[ info.name,
                                        info.type,
                                        info.hostName,
                                        info.domain,
                                        @(info.port).stringValue,
                                        info.IP ]];
    [_tableView reloadData];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"
        indexPath:indexPath
        nilBlock:^__kindof UITableViewCell *(NSIndexPath *indexPath) {
            return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
        }
        initBlock:^(__kindof UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            cell.detailTextLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        }];

    cell.textLabel.text = _cellTitles[indexPath.row];
    cell.detailTextLabel.text = _cellDetail[indexPath.row];
    return cell;
}

@end
