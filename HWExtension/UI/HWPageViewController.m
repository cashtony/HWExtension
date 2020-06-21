//
//  HWPageViewController.m
//  HWExtension
//
//  Created by Wang,Houwen on 2020/4/6.
//  Copyright © 2020 Wang,Houwen. All rights reserved.
//

#import "HWPageViewController.h"

@interface HWPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIPageViewController *pageVC;
@property (nonatomic, strong) NSMapTable<NSNumber *, UIViewController<HWPageViewControllerContent> *> *contentMap;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableOrderedSet<UIViewController<HWPageViewControllerContent> *> *> *reusableContentPool;

@end

@implementation HWPageViewController

- (instancetype)init {
    if (self = [super init]) {
        _currentPage = NSNotFound;
        _contentMap = [NSMapTable strongToWeakObjectsMapTable];
        _reusableContentPool = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.backgroundImageView];
    [self reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _backgroundImageView.frame = self.view.bounds;
    _pageVC.view.frame = self.view.bounds;
}

- (UIScrollView *)scrollView {
    __block UIScrollView *rt = nil;
    [self.pageVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            rt = (UIScrollView *)obj;
            *stop = YES;
        }
    }];
    return rt;
}

- (void)reloadData {
    [_contentMap removeAllObjects];
    // 由于UIPageViewController会缓存前后2个即将显示的vc, 导致pageVC滑动时代理方法回调的是之前的vc, 所以reload时需要丢弃之前的的缓存
    [self resetPageVC];
    _numberOfPages = [self callDataSourceToGetNumberOfPages];
    if (_numberOfPages) {
        [self scrollToPage:0 animated:NO];
    }
}

- (nullable UIViewController<HWPageViewControllerContent> *)contentAtPage:(NSInteger)page {
    if (page == _currentPage) {
        return [_contentMap objectForKey:@(page)];
    }
    return nil;
}

- (nullable UIViewController<HWPageViewControllerContent> *)visibleContent {
    return _pageVC.viewControllers.firstObject;
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated {
    NSString *assert = [NSString stringWithFormat:@"page %ld out of range [0, %ld]", page, _numberOfPages];
    NSAssert(page >= 0 && page < _numberOfPages, assert);
    UIPageViewControllerNavigationDirection direction = (page > _currentPage) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self setPageViewControllerAtPage:page direction:direction animated:animated];
}

- (nullable __kindof UIViewController<HWPageViewControllerContent> *)dequeueReusableContentWithId:(NSString *)iden {
    if (iden) {
        for (UIViewController<HWPageViewControllerContent> *content in _reusableContentPool[iden]) {
            if (![content isEqual:_pageVC.viewControllers.firstObject] &&
                ![content isEqual:[_contentMap objectForKey:@(_currentPage - 1)]] &&
                ![content isEqual:[_contentMap objectForKey:@(_currentPage + 1)]]) {
                if ([content respondsToSelector:@selector(prepareForReuse)]) {
                    [content prepareForReuse];
                }
                return content;
            }
        }
    }
    return nil;
}

#pragma mark - UIPageViewControllerDelegate, UIPageViewControllerDataSource

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
               viewControllerBeforeViewController:(UIViewController *)viewController {
    if (_numberOfPages) {
        NSInteger page = [self pageForContent:viewController];
        if (page != NSNotFound && page > 0) {
            return [self callDataSourceToGetContentForPage:page - 1];
        }
    }
    return nil;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
                viewControllerAfterViewController:(UIViewController *)viewController {
    if (_numberOfPages) {
        NSInteger page = [self pageForContent:viewController];
        if (page != NSNotFound && page < _numberOfPages - 1) {
            return [self callDataSourceToGetContentForPage:page + 1];
        }
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    UIViewController<HWPageViewControllerContent> *toVC = (id)pendingViewControllers.firstObject;
    NSInteger page = [self pageForContent:toVC];
    [self callDelegateForWillDisplay:toVC page:page];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
         didFinishAnimating:(BOOL)finished
    previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
        transitionCompleted:(BOOL)completed {
    if (completed) {
        UIViewController<HWPageViewControllerContent> *vc = pageViewController.viewControllers.firstObject;
        NSInteger page = [self pageForContent:vc];
        [self callDelegateForDidDisplay:vc page:page];
        for (UIViewController <HWPageViewControllerContent>*vc in previousViewControllers) {
            [self callDelegateForDidEndDisplaying:vc page:[self pageForContent:vc]];
        }
    }
}

#pragma mark - private

- (void)resetPageVC {
    [_pageVC.view removeFromSuperview];
    [_pageVC removeFromParentViewController];
    _pageVC = nil;
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
}

- (NSInteger)pageForContent:(UIViewController *)content {
    NSInteger page = NSNotFound;
    for (NSNumber *nPage in NSAllMapTableKeys(_contentMap)) {
        if ([[_contentMap objectForKey:nPage] isEqual:content]) {
            page = nPage.integerValue;
            break;
        }
    }
    return page;
}

// 切换 ViewController
- (void)setPageViewControllerAtPage:(NSUInteger)page
                          direction:(UIPageViewControllerNavigationDirection)direction
                           animated:(BOOL)animated {
    UIViewController<HWPageViewControllerContent> *curContent = _pageVC.viewControllers.firstObject;
    UIViewController<HWPageViewControllerContent> *content = [self callDataSourceToGetContentForPage:page];
    [self callDelegateForWillDisplay:content page:page];

    if (![content isEqual:_pageVC.viewControllers.firstObject]) {
        [_pageVC setViewControllers:@[ content ] direction:direction animated:animated completion:nil];
    }
    [self callDelegateForDidDisplay:content page:page];
    if (curContent && ![curContent isEqual:content]) {
        [self callDelegateForDidEndDisplaying:curContent page:page];
    }
}

#pragma mark - call dataSource、delegate

- (NSInteger)callDataSourceToGetNumberOfPages {
    NSInteger rt = 0;
    if ([_dataSource respondsToSelector:@selector(numberOfPagesInPageVC:)]) {
        rt = [_dataSource numberOfPagesInPageVC:self];
    }
    return rt;
}

- (UIViewController<HWPageViewControllerContent> *)callDataSourceToGetContentForPage:(NSInteger)page {
    NSAssert([_dataSource respondsToSelector:@selector(pageVC:contentForPage:)], @"pageVC:contentForPage: method must implementation!!!");
    UIViewController<HWPageViewControllerContent> *content = [_dataSource pageVC:self contentForPage:page];
    NSAssert(content, @"content can not be nil!!!");
    // add to reusable pool
    if ([content respondsToSelector:@selector(reuseIdentifier)]) {
        if (content.reuseIdentifier) {
            NSMutableOrderedSet *cs = _reusableContentPool[content.reuseIdentifier];
            if (!cs) {
                cs = [NSMutableOrderedSet orderedSet];
                _reusableContentPool[content.reuseIdentifier] = cs;
            }
            [cs removeObject:content];
            [cs addObject:content];
            if (cs.count > 3) {
                [cs removeObjectsInRange:NSMakeRange(0, cs.count - 3)];
            }
        }
    }
    NSInteger oPage = [self pageForContent:content];
    if (oPage != NSNotFound) {
        [_contentMap removeObjectForKey:@(oPage)];
    }
    [_contentMap setObject:content forKey:@(page)];
    return content;
}

- (void)callDelegateForWillDisplay:(UIViewController<HWPageViewControllerContent> *)content page:(NSInteger)page {
    if ([_delegate respondsToSelector:@selector(pageVC:willDisplayContent:forPage:)]) {
        [_delegate pageVC:self willDisplayContent:content forPage:page];
    }
}

- (void)callDelegateForDidDisplay:(UIViewController<HWPageViewControllerContent> *)content page:(NSInteger)page {
    if ([_delegate respondsToSelector:@selector(pageVC:didDisplayContent:forPage:)]) {
        [_delegate pageVC:self didDisplayContent:content forPage:page];
    }
    _currentPage = page;
}

- (void)callDelegateForDidEndDisplaying:(UIViewController<HWPageViewControllerContent> *)content page:(NSInteger)page {
    if ([_delegate respondsToSelector:@selector(pageVC:didEndDisplayingContent:forPage:)]) {
        [_delegate pageVC:self didEndDisplayingContent:content forPage:page];
    }
    if ([content respondsToSelector:@selector(didEndDisplaying)]) {
        [content didEndDisplaying];
    }
}

#pragma mark - lazy load

- (UIPageViewController *)pageVC {
    if (!_pageVC) {
        _pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                  navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                options:nil];
        _pageVC.view.backgroundColor = [UIColor clearColor];
        _pageVC.dataSource = self;
        _pageVC.delegate = self;
    }
    return _pageVC;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _backgroundImageView;
}

@end
