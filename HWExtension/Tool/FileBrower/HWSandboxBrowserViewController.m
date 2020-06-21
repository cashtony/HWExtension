//
//  HWSandboxBrowserViewController.m
//  HWExtension
//
//  Created by wanghouwen on 2017/12/21.
//  Copyright © 2017年 wanghouwen. All rights reserved.
//

#import "HWSandboxBrowserViewController.h"

@interface HWSandboxBrowserViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;      //
@property (nonatomic, copy) NSString *currentPath;         //
@property (nonatomic, copy) NSArray <NSString *>*items;    //

@property (nonatomic, strong) UIImage *directoryIcon;    //
@property (nonatomic, strong) UIImage *fileIcon;         //

@end

@implementation HWSandboxBrowserViewController

#pragma mark - setter

- (void)setCurrentPath:(NSString *)currentPath {
    _currentPath = [currentPath copy];
    self.items = [HWFileHelper contentsOfDirectoryAtPath:currentPath error:NULL];
    [self addBackNavigationItemIfNeeded];
}

- (void)setItems:(NSArray<NSString *> *)items {
    _items = [items copy];
    [self.tableView reloadData];
}

#pragma mark - life cycle & layout

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ToolResources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    self.directoryIcon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_directory" ofType:@"jpg"]];
    self.fileIcon = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_file" ofType:@"jpg"]];
    [self initUI];
    self.currentPath = [HWFileHelper sandboxDirectoryWithType:HWSandboxDirectoryTypeHome];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)addBackNavigationItemIfNeeded {
    if (![self.currentPath isEqualToString:[HWFileHelper sandboxDirectoryWithType:HWSandboxDirectoryTypeHome]]) {
        __weak typeof(self) ws = self;
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:@"< 返回" actionHandler:^(UIBarButtonItem *item, UIButton *customView) {
            __strong typeof(ws) ss = ws;
            [ss goBack];
        }];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)initUI {
    if (self.tableView.superview == nil) {
        [self.view addSubview:self.tableView];
        __weak typeof(self) ws = self;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:@"+" actionHandler:^(UIBarButtonItem *item, UIButton *customView) {
            __strong typeof(ws) ss = ws;
            [ss creatNewFile];
        }];
    }
}

#pragma mark -

- (void)goBack {
    self.currentPath = self.currentPath.stringByDeletingLastPathComponent;
}

- (void)creatNewFile {
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
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
    NSString *selectPathComponent = self.items[indexPath.row];
    
    NSString *filePath = [self.currentPath stringByAppendingPathComponent:selectPathComponent];
    if ([HWFileHelper isDirectoryAtPath:filePath]) {
        self.currentPath = filePath;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *filePath = [self.currentPath
                          stringByAppendingPathComponent:self.items[indexPath.row]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" indexPath:indexPath nilBlock:^__kindof UITableViewCell * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];
    } initBlock:^(__kindof UITableViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath) {
        
    }];
    
    cell.textLabel.text = self.items[indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    BOOL isDirectory = [HWFileHelper isDirectoryAtPath:filePath];
    cell.imageView.image = isDirectory ? self.directoryIcon : self.fileIcon;
    CGSize aspectSize = [cell.imageView aspectScaleToFitSize:CGSizeMake(45, 45)];
    cell.imageView.image = [cell.imageView.image reSizeToSize:aspectSize];
    
    NSDate *modiDate = [[HWFileHelper attributesOfItemAtPath:filePath error:NULL] fileModificationDate];
    cell.detailTextLabel.text = [@"上次修改：" stringByAdd:[modiDate stringWithFormat:@"yyyy.MM.dd HH:mm:ss:SS"]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [HWFileHelper removeItemAtPath:[self.currentPath stringByAppendingPathComponent:self.items[indexPath.row]] error:NULL];
    self.currentPath = self.currentPath;
}

#pragma mark - lazy load

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [UITableView groupedStyleTableViewWithFrame:CGRectZero delegate:self dataSource:self];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
