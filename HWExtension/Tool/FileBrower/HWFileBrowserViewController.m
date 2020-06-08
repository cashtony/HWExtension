//
//  HWFileBrowserViewController.m
//  HWExtension
//
//  Created by wanghouwen on 2017/12/21.
//  Copyright © 2017年 wanghouwen. All rights reserved.
//

#import "HWFileBrowserViewController.h"
#import "UIBarButtonItem+Category.h"
#import "UITableView+Category.h"
#import "UIImageView+Category.h"
#import "UIImage+Category.h"
#import "NSDate+Category.h"
#import "HWFileContentBrowserViewController.h"

@interface HWFileBrowserViewController () 

@property (nonatomic, copy) NSString *rootPath;

@property (nonatomic, strong) UITableView *tableView;      //
@property (nonatomic, copy) NSString *currentPath;         //
@property (nonatomic, copy) NSArray <NSString *>*items;    //

@property (nonatomic, strong) UIImage *directoryIcon;    //
@property (nonatomic, strong) UIImage *fileIcon;         //
@property (nonatomic, strong) UILabel *titleView;

@end

@implementation HWFileBrowserViewController

#pragma mark - init

- (instancetype)initWithRootPath:(NSString *)rootPath {
    if (self=[super initWithNibName:nil bundle:nil]) {
        self.rootPath = rootPath;
        self.currentPath = rootPath;
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        _titleView.numberOfLines = 0;
        _titleView.adjustsFontSizeToFitWidth = YES;
        _titleView.text = rootPath;
    }
    return self;
}

- (NSString *)pathAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _items.count)
    {
        return [_currentPath stringByAppendingPathComponent:_items[indexPath.row]];
    } else
    {
        return nil;
    }
}

- (NSComparisonResult)sortResultForFile1:(NSString *)file1 file2:(NSString *)file2
{
    return [[HWFileHelper fileModificationDateOfItemAtPath:file1 error:nil] compare:[HWFileHelper fileModificationDateOfItemAtPath:file2 error:nil]];
}

#pragma mark - setter

- (void)setCurrentPath:(NSString *)currentPath {
    _currentPath = [currentPath copy];
    NSMutableArray <NSString *>*cs = [[HWFileHelper contentsOfDirectoryAtPath:currentPath error:NULL] mutableCopy];
    
    __weak typeof(self) ws = self;
    [cs sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2)
    {
        return [ws sortResultForFile1:[currentPath stringByAppendingPathComponent:obj1] file2:[currentPath stringByAppendingPathComponent:obj2]];
    }];
    self.items = cs;
    [self addBackNavigationItemIfNeeded];
    _titleView.text = currentPath;
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
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)addBackNavigationItemIfNeeded {
    if (![self.currentPath isEqualToString:_rootPath]) {
        __weak typeof(self) ws = self;
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:@"返回" actionHandler:^(UIBarButtonItem *item, UIButton *customView) {
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
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:@"reload" actionHandler:^(UIBarButtonItem *item, UIButton *customView) {
            __strong typeof(ws) ss = ws;
            [ss reload];
        }];
        self.navigationItem.titleView = _titleView;
    }
}

- (void)reload
{
    self.currentPath = _currentPath;
}

- (void)updateRootPath:(NSString *)rootPath {
    self.rootPath = [rootPath copy];
    self.currentPath = [rootPath copy];
}

#pragma mark -

- (void)goBack {
    self.currentPath = self.currentPath.stringByDeletingLastPathComponent;
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
    } else {
        HWFileContentBrowserViewController *vc = [HWFileContentBrowserViewController new];
        vc.filePath = filePath;
        [self.navigationController pushViewController:vc animated:YES];
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
    
    NSDate *modiDate = [HWFileHelper fileModificationDateOfItemAtPath:filePath error:nil];
    cell.detailTextLabel.text = [@"修改：" stringByAppendingString:modiDate ? [modiDate stringWithFormat:@"yyyy.MM.dd HH:mm:ss:SS"] : @"--"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 某些iOS8.0以上系统不会触发左滑操作, 必须实现以下2个方法
- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self editActions];
}

#pragma mark - lazy load

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [UITableView groupedStyleTableViewWithFrame:CGRectZero delegate:self dataSource:self];
    }
    return _tableView;
}

#pragma mark - private

- (NSArray <UITableViewRowAction *>*)editActions
{
    __weak typeof(self) ws = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [ws.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [HWFileHelper removeItemAtPath:[ws.currentPath stringByAppendingPathComponent:ws.items[indexPath.row]] error:NULL];
        ws.currentPath = ws.currentPath;
    }];
    deleteAction.backgroundColor = [UIColor colorWithRed:249/255.f green:79/255.f blue:79/255.f alpha:1.f];
    
    return @[deleteAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
