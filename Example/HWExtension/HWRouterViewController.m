//
//  HWRouterViewController.m
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/3/6.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import "HWRouterViewController.h"
#import "HWCategorys.h"
#import "HWRouter.h"

@interface HWRouterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;    //

@end

@implementation HWRouterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    if (self.tableView.superview == nil) {
        self.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.tableView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [UITableView plainStyleTableViewWithFrame:CGRectZero delegate:self dataSource:self];
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [HWRouter routeURL:cell.textLabel.text.hw_URL options:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" indexPath:indexPath nilBlock:^__kindof UITableViewCell * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [UITableViewCell value1StyleCellWithReuseIdentifier:@"cellID"];
    } initBlock:^(__kindof UITableViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }];
    
    NSArray <NSString *>*urls = @[@"RouterSubVC://routerSubVC1?p1=1&p2=sub1",
                                  @"RouterSubVC://routerSubVC2?showType=auto&animated=1&p1=2&p2=sub2",
                                  @"Other://routerSubVC3?showType=present&animated=1&p1=3&p2=sub3",
                                  @"RouterSubVC://routerSubVC3?showType=present&animated=1&p1=4&p2=sub4"];
    
    cell.textLabel.text = urls[indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
