//
//  HWGroupViewController.m
//  HWExtension
//
//  Created by Wang,Houwen on 2020/4/7.
//  Copyright © 2020 Wang,Houwen. All rights reserved.
//

#import "HWGroupViewController.h"
#import "HWPageViewController.h"
#import <objc/message.h>
#import "Masonry.h"

#define kGroupBarHeight 51.f
#define kPageBarHeight 36.f
void *ObserverContext = "HWGroupViewControllerObserverContext";

@interface UITableView (HWGroupViewController)

@property (nonatomic, assign) BOOL updatingVisibleCells;

@end

@implementation UITableView (HWGroupViewController)

+ (void)hook_UpdateVisibleCellsNow {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method m1 = class_getInstanceMethod(self.class, @selector(_updateVisibleCellsNow:));
        if (m1) {
            Method m2 = class_getInstanceMethod(self.class, @selector(hw_updateVisibleCellsNow:));
            if (strcmp(method_getTypeEncoding(m1), method_getTypeEncoding(m2)) == 0) {
                method_exchangeImplementations(m1, m2);
            }
        }
    });
#pragma clang diagnostic pop
}

- (void)hw_updateVisibleCellsNow:(BOOL)arg {
    self.updatingVisibleCells = YES;
    [self hw_updateVisibleCellsNow:arg];
    self.updatingVisibleCells = NO;
}

- (BOOL)updatingVisibleCells {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setUpdatingVisibleCells:(BOOL)updatingVisibleCells {
    objc_setAssociatedObject(self, @selector(updatingVisibleCells), @(updatingVisibleCells), OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation HWGroupViewControllerBarItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _contentButton.userInteractionEnabled = NO;
        [self.contentView addSubview:_contentButton];
        _badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_badgeLabel];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [_contentButton setHighlighted:highlighted];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [_contentButton setSelected:selected];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentButton.frame = self.bounds;
    [_badgeLabel sizeToFit];
    CGRect rect = _badgeLabel.frame;
    rect.origin.y = 0;
    rect.origin.x = self.bounds.size.width - rect.size.width;
    _badgeLabel.frame = rect;
}

@end

@interface HWGroupViewControllerTableView : UITableView

@property (nonatomic, copy) BOOL (^shouldRecognizeSimultaneously)(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer);

@end

@implementation HWGroupViewControllerTableView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return _shouldRecognizeSimultaneously ? _shouldRecognizeSimultaneously(gestureRecognizer, otherGestureRecognizer) : NO;
}

@end

@interface HWGroupViewController () <HWPageViewControllerDataSource,
                                     HWPageViewControllerDelegate,
                                     HWTabBarDataSource,
                                     HWTabBarDelegate,
                                     UITableViewDataSource,
                                     UITableViewDelegate>

@property (nonatomic, strong) NSMapTable<UIScrollView *, NSNumber *> *contentOffsetMap;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) HWGroupViewControllerTableView *tableView;
@property (nonatomic, strong) HWTabBar *groupBar;
@property (nonatomic, strong) HWTabBar *pageBar;
@property (nonatomic, strong) HWPageViewController *pageVC;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *numberOfPagesMap;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *selectPageMap;
@property (nonatomic, strong) NSMutableSet<NSHashTable<__kindof UIScrollView *> *> *observedScrollViews;

@end

@implementation HWGroupViewController

- (instancetype)init {
    if (self = [super init]) {
        [UITableView hook_UpdateVisibleCellsNow];
        _numberOfPagesMap = [NSMutableDictionary dictionary];
        _selectPageMap = [NSMutableDictionary dictionary];
        _observedScrollViews = [NSMutableSet set];
        _contentOffsetMap = [NSMapTable weakToStrongObjectsMapTable];
        self.headerView = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
    [self initUI];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backgroundImageView];
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [self.view addSubview:self.tableView];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    __weak typeof(self) ws = self;
    self.tableView.shouldRecognizeSimultaneously = ^BOOL(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer) {
        id<HWGroupViewControllerContent> ct = (id)ws.pageVC.visibleContent;
        UIScrollView *contentScrollView = nil;
        if ([ct respondsToSelector:@selector(scrollView)]) {
            contentScrollView = [ct scrollView];
        }
        if (contentScrollView && [@[ @"_UIQueuingScrollView", @"UIScrollViewPanGestureRecognizer" ] containsObject:NSStringFromClass([otherGestureRecognizer class])]) {
            return YES;
        }
        return NO;
    };

//    _tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
//        NSIndexPath *indexPath = ws.selectedPageAtIndexPath;
//        if (indexPath) {
//            if ([ws.delegate respondsToSelector:@selector(groupVCBeginRefreshing:)]) {
//                [ws.delegate groupVCBeginRefreshing:ws];
//            }
//        }
//    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addObserverToScrollView:self.tableView];
    [self addObserverToScrollView:self.pageVC.scrollView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_tableView reloadData];
}

#pragma mark - public

- (void)setEnableSwipe:(BOOL)enableSwipe {
    _enableSwipe = enableSwipe;
    _pageVC.scrollView.scrollEnabled = _enableSwipe;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
}

- (void)setHeaderView:(UIView *)headerView {
    _headerView = headerView;
    if (![_groupBar.superview isEqual:_tableView]) {
        [_groupBar removeFromSuperview];
    }
    if (headerView) {
        self.tableView.tableHeaderView = headerView;
        [headerView addSubview:self.groupBar];
        [_groupBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.bottom.equalTo(@0);
            make.height.equalTo(@(kGroupBarHeight));
        }];
    } else {
        self.groupBar.frame = CGRectMake(0, 0, self.view.frame.size.width, kGroupBarHeight);
        self.tableView.tableHeaderView = _groupBar;
    }
    [self.tableView reloadData];
}

- (nullable UIViewController<HWGroupViewControllerContent> *)visibleContent {
    return (id)_pageVC.visibleContent;
}

- (NSInteger)numberOfPagesInGroup:(NSInteger)group {
    return _numberOfPagesMap[@(group)].integerValue;
}

- (nullable __kindof UIViewController<HWGroupViewControllerContent> *)dequeueReusableContentWithId:(NSString *)iden {
    return [_pageVC dequeueReusableContentWithId:iden];
}

- (NSIndexPath *)selectedPageAtIndexPath {
    if (_groupBar.selectedItemIndex != NSNotFound && _pageBar.selectedItemIndex != NSNotFound) {
        return [NSIndexPath indexPathForPage:_pageBar.selectedItemIndex inGroup:_groupBar.selectedItemIndex];
    }
    return nil;
}

- (void)selectPageAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    NSString *groupAssert = [NSString stringWithFormat:@"group %ld out of range [0, %ld]", indexPath.group, _groupBar.numberOfItems];
    NSString *pageAssert = [NSString stringWithFormat:@"page %ld out of range [0, %ld]", indexPath.page, _pageBar.numberOfItems];
    NSAssert(indexPath.group < _groupBar.numberOfItems, groupAssert);
    NSAssert(indexPath.page < _pageBar.numberOfItems, pageAssert);
    BOOL needReloadPageBar = indexPath.group != _groupBar.selectedItemIndex;
    [_groupBar selectItemAtIndex:indexPath.group animated:animated scrollPosition:HWTabBarScrollPositionCenter];
    !needReloadPageBar ?: [_pageBar reloadData];
    [_pageBar selectItemAtIndex:indexPath.page animated:animated scrollPosition:HWTabBarScrollPositionCenter];
    [_pageVC scrollToPage:indexPath.page animated:animated];
}

- (void)endRefreshing {
//    [_tableView.mj_header endRefreshing];
}

- (void)reloadData {
    _numberOfGroups = 0;
    [_numberOfPagesMap removeAllObjects];
    [_selectPageMap removeAllObjects];

//    [_tableView.mj_header endRefreshing];

    [self.groupBar reloadData];
    [self.pageBar reloadData];

    [self callDataSourceToGetNumberOfGroups];
    if (_numberOfGroups) {
        [self callDataSourceToGetNumberOfPagesInGroup:0];
        [self.groupBar selectItemAtIndex:0 animated:NO scrollPosition:HWTabBarScrollPositionCenter];
        if ([self numberOfPagesInGroup:0]) {
            [self.pageBar selectItemAtIndex:0 animated:NO scrollPosition:HWTabBarScrollPositionCenter];
        }
    }
    [self removeObserverForScrollView:_pageVC.scrollView];
    [self.pageVC reloadData];
    [self addObserverToScrollView:_pageVC.scrollView];
}

#pragma mark - HWPageViewControllerDataSource, HWPageViewControllerDelegate

- (NSInteger)numberOfPagesInPageVC:(HWPageViewController *)pageVC {
    if (_groupBar.selectedItemIndex != NSNotFound) {
        return [self callDataSourceToGetNumberOfPagesInGroup:_groupBar.selectedItemIndex];
    }
    return 0;
}

- (nonnull UIViewController<HWPageViewControllerContent> *)pageVC:(HWPageViewController *)pageVC contentForPage:(NSInteger)page {
    return (id)[self callDataSourceToGetContentForPageAtIndexPath:[NSIndexPath indexPathForPage:page inGroup:_groupBar.selectedItemIndex]];
}

- (void)pageVC:(HWPageViewController *)pageVC willDisplayContent:(UIViewController<HWPageViewControllerContent> *)content forPage:(NSInteger)page {
    [self callDelegateForWillDisplayContent:(id)content forPageAtIndexPath:[NSIndexPath indexPathForPage:page inGroup:_groupBar.selectedItemIndex]];
}

- (void)pageVC:(HWPageViewController *)pageVC didDisplayContent:(UIViewController<HWPageViewControllerContent> *)content forPage:(NSInteger)page {
    [_pageBar selectItemAtIndex:page animated:YES scrollPosition:HWTabBarScrollPositionCenter];
    [self callDelegateForDidDisplayContent:(id)content forPageAtIndexPath:[NSIndexPath indexPathForPage:page inGroup:_groupBar.selectedItemIndex]];
    UIViewController<HWGroupViewControllerContent> *ct = (id)content;
    if ([ct respondsToSelector:@selector(scrollView)]) {
        [self addObserverToScrollView:ct.scrollView];
        if (@available(iOS 11.0, *)) {
            ct.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            ct.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
        }
    }
    _selectPageMap[@(_groupBar.selectedItemIndex)] = @(page);
    _pageVC.scrollView.scrollEnabled = _enableSwipe;
}

- (void)pageVC:(HWPageViewController *)pageVC didEndDisplayingContent:(UIViewController<HWPageViewControllerContent> *)content forPage:(NSInteger)page {
    UIViewController<HWGroupViewControllerContent> *ct = (id)content;
    if ([ct respondsToSelector:@selector(scrollView)]) {
        [self removeObserverForScrollView:ct.scrollView];
    }
}

#pragma mark - HWTabBarDataSource, HWTabBarDelegate

- (NSInteger)numberOfItemsInTabBar:(HWTabBar *)tabBar {
    if (_numberOfGroups <= 0) {
        _numberOfGroups = [self callDataSourceToGetNumberOfGroups];
    }
    if ([tabBar isEqual:_groupBar]) {
        return _numberOfGroups;
    } else {
        if (_numberOfGroups && _groupBar.selectedItemIndex != NSNotFound) {
            return [self callDataSourceToGetNumberOfPagesInGroup:_groupBar.selectedItemIndex];
        }
    }
    return 0;
}

- (UICollectionViewCell *)tabBar:(HWTabBar *)tabBar itemAtIndex:(NSInteger)index {
    return [tabBar dequeueReusableItemWithReuseIdentifier:[self reuseIdentifierForBar:tabBar] forIndex:index];
}

- (NSInteger)numberOfToolItemsInTabBar:(HWTabBar *)tabBar position:(HWTabBarPosition)position {
    if ([_dataSource respondsToSelector:@selector(groupVC:numberOfToolItemsAtToolPosition:barPosition:)]) {
        return [_dataSource groupVC:self numberOfToolItemsAtToolPosition:position barPosition:[self positionForBar:tabBar]];
    }
    return 0;
}

- (HWTabBarToolItem *)tabBar:(HWTabBar *)tabBar toolItemAtIndex:(NSInteger)index position:(HWTabBarPosition)position {
    if ([_dataSource respondsToSelector:@selector(groupVC:toolItemAtIndex:toolPosition:barPosition:)]) {
        return [_dataSource groupVC:self toolItemAtIndex:index toolPosition:position barPosition:[self positionForBar:tabBar]];
    }
    return nil;
}

- (CGFloat)tabBar:(HWTabBar *)tabBar widthForItemAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(groupVC:widthForBarItemAtIndex:barPosition:)]) {
        return [_delegate groupVC:self widthForBarItemAtIndex:index barPosition:[self positionForBar:tabBar]];
    }
    return 0.f;
}

- (CGFloat)tabBar:(HWTabBar *)tabBar widthForAnimationLineAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(groupVC:widthForBarItemAtIndex:barPosition:)]) {
        return [_delegate groupVC:self widthForBarAnimationLineAtIndex:index barPosition:[self positionForBar:tabBar]];
    }
    return 0.f;
}

- (CGFloat)tabBar:(HWTabBar *)tabBar widthForToolItemAtIndex:(NSInteger)index position:(HWTabBarPosition)position {
    if ([_delegate respondsToSelector:@selector(groupVC:widthForBarToolItemAtIndex:toolPosition:barPosition:)]) {
        return [_delegate groupVC:self widthForBarToolItemAtIndex:index toolPosition:position barPosition:[self positionForBar:tabBar]];
    }
    return 0.f;
}

- (void)tabBar:(HWTabBar *)tabBar willDisplayItem:(UICollectionViewCell *)item forIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(groupVC:willDisplayBarItem:forIndex:barPosition:)]) {
        [_delegate groupVC:self willDisplayBarItem:(id)item forIndex:index barPosition:[self positionForBar:tabBar]];
    }
}

- (void)tabBar:(HWTabBar *)tabBar willDisplayToolItem:(HWTabBarToolItem *)toolItem forIndex:(NSInteger)index position:(HWTabBarPosition)position {
    if ([_delegate respondsToSelector:@selector(groupVC:willDisplayBarToolItem:forIndex:toolPosition:barPosition:)]) {
        [_delegate groupVC:self willDisplayBarToolItem:toolItem forIndex:index toolPosition:position barPosition:[self positionForBar:tabBar]];
    }
}

- (void)tabBar:(HWTabBar *)tabBar didSelectItem:(UICollectionViewCell *)item atIndex:(NSInteger)index lastSelectIndex:(NSInteger)lastSelect {
    if ([tabBar isEqual:_groupBar]) {
        [self callDelegateWillSelectGroup:index];
        [_groupBar selectItemAtIndex:index animated:YES scrollPosition:HWTabBarScrollPositionCenter];
        [self callDelegateDidSelectGroup:index];
        [_pageBar reloadData];
        NSInteger page = _selectPageMap[@(index)].integerValue;
        if (page < _pageBar.numberOfItems) {
            [_pageBar selectItemAtIndex:page animated:NO scrollPosition:HWTabBarScrollPositionCenter];
            [self removeObserverForScrollView:_pageVC.scrollView];
            [_pageVC reloadData];
            [_pageVC scrollToPage:page animated:NO];
            [self addObserverToScrollView:_pageVC.scrollView];
        } else {
           [self removeObserverForScrollView:_pageVC.scrollView];
            [_pageVC reloadData];
            [self addObserverToScrollView:_pageVC.scrollView];
        }
    } else if ([tabBar isEqual:_pageBar]) {
        [_pageVC scrollToPage:index animated:NO];
    }
}

- (void)tabBar:(HWTabBar *)tabBar didSelectToolItem:(HWTabBarToolItem *)toolItem atIndex:(NSInteger)index position:(HWTabBarPosition)position {
    if ([_delegate respondsToSelector:@selector(groupVC:didSelectBarToolItem:atIndex:toolPosition:barPosition:)]) {
        [_delegate groupVC:self didSelectBarToolItem:toolItem atIndex:index toolPosition:position barPosition:[self positionForBar:tabBar]];
    }
}

#pragma mark - call dataSource、delegate

- (NSInteger)callDataSourceToGetNumberOfGroups {
    NSInteger rt = 0;
    if ([_dataSource respondsToSelector:@selector(numberOfGroupsInGroupVC:)]) {
        rt = [_dataSource numberOfGroupsInGroupVC:self];
        _numberOfGroups = rt;
    }
    return rt;
}

- (NSInteger)callDataSourceToGetNumberOfPagesInGroup:(NSInteger)group {
    NSInteger rt = 0;
    if ([_dataSource respondsToSelector:@selector(groupVC:numberOfPagesInGroup:)]) {
        rt = [_dataSource groupVC:self numberOfPagesInGroup:group];
        _numberOfPagesMap[@(group)] = @(rt);
    }
    return rt;
}

- (UIViewController<HWGroupViewControllerContent> *)callDataSourceToGetContentForPageAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert([_dataSource respondsToSelector:@selector(groupVC:contentForPageAtIndexPath:)], @"groupVC:contentForPageAtIndexPath: method must implementation!!!");
    UIViewController<HWGroupViewControllerContent> *rt = [_dataSource groupVC:self contentForPageAtIndexPath:indexPath];
    NSAssert(rt, @"content can not be nil!!!");
    return rt;
}

- (void)callDelegateForWillDisplayContent:(UIViewController<HWGroupViewControllerContent> *)content forPageAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(groupVC:willDisplayContent:forPageAtIndexPath:)]) {
        [_delegate groupVC:self willDisplayContent:content forPageAtIndexPath:indexPath];
    }
}

- (void)callDelegateForDidDisplayContent:(UIViewController<HWGroupViewControllerContent> *)content forPageAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(groupVC:didDisplayContent:forPageAtIndexPath:)]) {
        [_delegate groupVC:self didDisplayContent:(id)content forPageAtIndexPath:indexPath];
    }
}

- (void)callDelegateWillSelectGroup:(NSInteger)group {
    if ([_delegate respondsToSelector:@selector(groupVC:willSelectGroup:)]) {
        [_delegate groupVC:self willSelectGroup:group];
    }
}

- (void)callDelegateDidSelectGroup:(NSInteger)group {
    if ([_delegate respondsToSelector:@selector(groupVC:didSelectGroup:)]) {
        [_delegate groupVC:self didSelectGroup:group];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellID"];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        [self addChildViewController:self.pageVC];
        [cell.contentView addSubview:self.pageVC.view];
        [self.pageVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size.height - kPageBarHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kPageBarHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _pageBar;
}

#pragma mark - private

- (void)dealloc {
    [_observedScrollViews.allObjects enumerateObjectsUsingBlock:^(NSHashTable<__kindof UIScrollView *> *obj, NSUInteger idx, BOOL *stop) {
        [self removeObserverForScrollView:obj.anyObject];
    }];
}

- (HWGroupViewControllerBarPosition)positionForBar:(HWTabBar *)bar {
    if ([bar isEqual:_groupBar]) {
        return HWGroupViewControllerBarPositionGroup;
    } else if ([bar isEqual:_pageBar]) {
        return HWGroupViewControllerBarPositionPage;
    }
    NSAssert(1, @"Error!!!");
    return -1;
}

- (NSString *)reuseIdentifierForBar:(HWTabBar *)bar {
    if ([bar isEqual:_groupBar]) {
        return @"groupBar";
    } else if ([bar isEqual:_pageBar]) {
        return @"pageBar";
    }
    return nil;
}

- (void)addObserverToScrollView:(UIScrollView *)scrollView {
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:ObserverContext];
    NSHashTable *table = [NSHashTable weakObjectsHashTable];
    [table addObject:scrollView];
    [_observedScrollViews addObject:table];
}

- (void)removeObserverForScrollView:(UIScrollView *)scrollView {
    [scrollView removeObserver:self forKeyPath:@"contentOffset" context:ObserverContext];
    NSMutableSet <NSHashTable <UIScrollView *>*>*removed = [NSMutableSet set];
    for (NSHashTable *table in _observedScrollViews) {
        if ([scrollView isEqual:table.anyObject]) {
            [removed addObject:table];
        }
    }
    for (int i = 0; i < removed.count; i++) {
        [_observedScrollViews removeObject:removed.anyObject];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (context != ObserverContext || ![keyPath isEqualToString:@"contentOffset"])
        return;

    _tableView.scrollEnabled = YES;
    id<HWGroupViewControllerContent> content = (id)_pageVC.visibleContent;
    UIScrollView *contentScrollView = nil;
    if ([content respondsToSelector:@selector(scrollView)]) {
        contentScrollView = [content scrollView];
        if (!contentScrollView) {
            return;
        }
        contentScrollView.scrollEnabled = YES;
        if ([contentScrollView isKindOfClass:[UITableView class]]) {
            if (((UITableView *)contentScrollView).updatingVisibleCells) {
                return;
            }
        }
    }
    CGFloat offsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
    if ([_contentOffsetMap objectForKey:object].floatValue == offsetY) {
        return;
    }
    [_contentOffsetMap setObject:@(offsetY) forKey:object];

    BOOL isTableView = [object isEqual:_tableView];
    BOOL isContentScrollView = [object isEqual:contentScrollView];
    BOOL isPageScrollView = [object isEqual:_pageVC.scrollView];

    if (isTableView || isContentScrollView || isPageScrollView) {
        BOOL enableScorll = YES;
        if ((int)_pageVC.visibleContent.view.bounds.size.width > 0.f) {
            enableScorll = ((int)_pageVC.scrollView.contentOffset.x) % ((int)_pageVC.visibleContent.view.bounds.size.width) < 5.f;
        }
        _tableView.scrollEnabled = enableScorll;
        contentScrollView.scrollEnabled = enableScorll;

        CGFloat headerViewH = self.tableView.tableHeaderView.frame.size.height;
        if (isTableView) {
            CGPoint offset = _tableView.contentOffset;
            if (offset.y >= headerViewH || contentScrollView.contentOffset.y > 0.f) {
                if (fabs(offset.y - headerViewH) > 0.3f) {
                    _tableView.contentOffset = CGPointMake(offset.x, headerViewH);
                }
            }
        } else if (isContentScrollView) {
            CGPoint offset = contentScrollView.contentOffset;
            if (offset.y < 0.f || headerViewH - _tableView.contentOffset.y > 0.3f) {
                if (offset.y != 0.f) {
                    contentScrollView.contentOffset = CGPointMake(offset.x, 0.f);
                }
            }
        }
    }
}

#pragma mark - lazy load

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _backgroundImageView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[HWGroupViewControllerTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (HWTabBar *)groupBar {
    if (!_groupBar) {
        _groupBar = [[HWTabBar alloc] initWithFrame:CGRectZero];
        _groupBar.dataSource = self;
        _groupBar.delegate = self;
        [_groupBar registerClass:[HWGroupViewControllerBarItem class] forItemWithReuseIdentifier:@"groupBar"];
    }
    return _groupBar;
}

- (HWTabBar *)pageBar {
    if (!_pageBar) {
        _pageBar = [[HWTabBar alloc] initWithFrame:CGRectZero];
        _pageBar.dataSource = self;
        _pageBar.delegate = self;
        [_pageBar registerClass:[HWGroupViewControllerBarItem class] forItemWithReuseIdentifier:@"pageBar"];
    }
    return _pageBar;
}

- (HWPageViewController *)pageVC {
    if (!_pageVC) {
        _pageVC = [[HWPageViewController alloc] init];
        _pageVC.dataSource = self;
        _pageVC.delegate = self;
        _pageVC.scrollView.scrollEnabled = _enableSwipe;
    }
    return _pageVC;
}

@end
