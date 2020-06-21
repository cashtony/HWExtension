//
//  HWTabBar.m
//  HWExtension
//
//  Created by Wang,Houwen on 2020/4/7.
//  Copyright © 2020 Wang,Houwen. All rights reserved.
//

#import "HWTabBar.h"

#define AnimationViewHeight 3.f

@implementation HWTabBarToolItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_button];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _button.frame = self.bounds;
}

@end

@interface HWTabBar () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) UICollectionReusableView *sectionHeader;
@property (nonatomic, strong) UICollectionReusableView *sectionFooter;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger lastSelect;
@property (nonatomic, assign) NSInteger currentSelect;
@property (nonatomic, strong) NSMutableArray<HWTabBarToolItem *> *leftToolItems;
@property (nonatomic, strong) NSMutableArray<HWTabBarToolItem *> *rightToolItems;
@property (nonatomic, assign) CGFloat referenceWidthForHeader;
@property (nonatomic, assign) CGFloat referenceWidthForFooter;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *leftToolItemsWidth;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *rightToolItemsWidth;
@property (nonatomic, assign) BOOL animationFailed;

@end

@implementation HWTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentSelect = NSNotFound;
        _lastSelect = NSNotFound;
        _referenceWidthForHeader = -1;
        _referenceWidthForFooter = -1;
        _leftToolItems = [NSMutableArray array];
        _rightToolItems = [NSMutableArray array];
        _leftToolItemsWidth = [NSMutableArray array];
        _rightToolItemsWidth = [NSMutableArray array];
        [self addSubview:self.collectionView];
        [_collectionView addSubview:self.animationView];
        self.animationView.frame = CGRectMake(0, 0, 0, AnimationViewHeight);
        self.animationView.layer.cornerRadius = AnimationViewHeight / 2.f;
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader"];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"sectionFooter"];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = _leftAccessoryView.frame;
    rect.origin = CGPointZero;
    rect.size.height = CGRectGetHeight(self.frame);
    _leftAccessoryView.frame = rect;

    rect = _rightAccessoryView.frame;
    rect.origin.x = CGRectGetWidth(self.frame) - CGRectGetWidth(rect);
    rect.origin.y = 0;
    rect.size.height = CGRectGetHeight(self.frame);
    _rightAccessoryView.frame = rect;

    _collectionView.frame = CGRectMake(CGRectGetMaxX(_leftAccessoryView.frame), 0, CGRectGetMinX(rect) - CGRectGetMaxX(_leftAccessoryView.frame), CGRectGetHeight(self.frame));
}

#pragma mark - public api

- (void)reloadData {
    _lastSelect = NSNotFound;
    _currentSelect = NSNotFound;
    _referenceWidthForHeader = -1;
    _referenceWidthForFooter = -1;
    _animationFailed = YES;
    _numberOfItems = 0;
    [_leftToolItems removeAllObjects];
    [_rightToolItems removeAllObjects];
    [_leftToolItemsWidth removeAllObjects];
    [_rightToolItemsWidth removeAllObjects];
    [_collectionView reloadData];
}

- (NSInteger)selectedItemIndex {
    return _currentSelect;
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(HWTabBarScrollPosition)scrollPosition {
    NSInteger max = [_collectionView numberOfItemsInSection:0];
    if (index >= max) {
        NSString *assert = [NSString stringWithFormat:@"index %ld out of range [0, %ld]", index, max];
        NSAssert(1, assert);
    }
    _currentSelect = index;
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:animated scrollPosition:scrollPosition];
    _lastSelect = index;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    self.collectionView.contentInset = contentInset;
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    _minimumInteritemSpacing = minimumInteritemSpacing;
    ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).minimumInteritemSpacing = minimumInteritemSpacing;
    NSInteger curIndex = self.currentSelect;
    [self.collectionView reloadData];
    if (_currentSelect != NSNotFound) {
        [self selectItemAtIndex:curIndex animated:NO scrollPosition:HWTabBarScrollPositionCenter];
    }
}

- (void)registerClass:(nullable Class)itemClass forItemWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:itemClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableItemWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (void)setLeftAccessoryView:(UIView *)leftAccessoryView {
    [_leftAccessoryView removeFromSuperview];
    _leftAccessoryView = leftAccessoryView;
    [self addSubview:leftAccessoryView];
    [self setNeedsLayout];
}

- (void)setRightAccessoryView:(UIView *)rightAccessoryView {
    [_rightAccessoryView removeFromSuperview];
    _rightAccessoryView = rightAccessoryView;
    [self addSubview:rightAccessoryView];
    [self setNeedsLayout];
}

- (void)setAnimationLineColor:(UIColor *)animationLineColor {
    _animationLineColor = animationLineColor;
    self.animationView.backgroundColor = animationLineColor;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger rt = 0;
    if ([_dataSource respondsToSelector:@selector(numberOfItemsInTabBar:)]) {
        rt = [_dataSource numberOfItemsInTabBar:self];
    }
    _numberOfItems = rt;
    _animationView.hidden = (_numberOfItems == 0);
    return rt;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return [self callDelegateToGetReferenceSizeAtPosition:HWTabBarPositionLeft];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return [self callDelegateToGetReferenceSizeAtPosition:HWTabBarPositionRight];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize rt = CGSizeMake(0, UIEdgeInsetsInsetRect(self.bounds, _contentInset).size.height);
    if ([_delegate respondsToSelector:@selector(tabBar:widthForItemAtIndex:)]) {
        rt.width = [_delegate tabBar:self widthForItemAtIndex:indexPath.item];
    }
    return rt;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [self callDataSourceToGetToolItemForSupplementaryElementOfKind:kind];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert([self.dataSource respondsToSelector:@selector(tabBar:itemAtIndex:)], @"the dataSource must implementation: tabBar:itemAtIndex:");
    UICollectionViewCell *cell = [_dataSource tabBar:self itemAtIndex:indexPath.item];
    if (!cell) {
        NSString *assert = [NSString stringWithFormat:@"itemAtIndex: %ld can not be nil", indexPath.item];
        NSAssert(1, assert);
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tabBar:willDisplayItem:forIndex:)]) {
        [_delegate tabBar:self willDisplayItem:cell forIndex:indexPath.item];
    }
    if (_animationFailed && self.selectedItemIndex != NSNotFound) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self animationToIndx:self.selectedItemIndex];
        });
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tabBar:willDisplayToolItem:forIndex:position:)]) {
        BOOL left = [elementKind isEqualToString:UICollectionElementKindSectionHeader];
        NSMutableArray *toolItems = left ? _leftToolItems : _rightToolItems;
        NSMutableArray *toolItemsWidth = left ? _leftToolItemsWidth : _rightToolItemsWidth;
        NSAssert(toolItems.count == toolItemsWidth.count, @"error toolItems count != tool items widths count");
        CGFloat x = 0.f;
        CGFloat height = self.bounds.size.height;
        for (int i = 0; i < toolItems.count; i++) {
            HWTabBarToolItem *toolItem = toolItems[i];
            toolItem.frame = CGRectMake(x, 0, [toolItemsWidth[i] floatValue], height);
            [_delegate tabBar:self willDisplayToolItem:toolItem forIndex:i position:(left ? HWTabBarPositionLeft : HWTabBarPositionRight)];
            x = CGRectGetMaxX(toolItem.frame);
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentSelect = indexPath.item;
    if ([_delegate respondsToSelector:@selector(tabBar:didSelectItem:atIndex:lastSelectIndex:)]) {
        [_delegate tabBar:self didSelectItem:[collectionView cellForItemAtIndexPath:indexPath] atIndex:indexPath.item lastSelectIndex:_lastSelect];
    }
    _lastSelect = indexPath.item;
    [self animationToIndx:indexPath.item];
}

#pragma mark - call dataSource、delegate

// 这个方法中有size缓存处理
- (CGSize)callDelegateToGetReferenceSizeAtPosition:(HWTabBarPosition)position {
    if (position == HWTabBarPositionLeft && _referenceWidthForHeader >= 0) {
        return CGSizeMake(_referenceWidthForHeader, self.bounds.size.height);
    } else if (position == HWTabBarPositionRight && _referenceWidthForFooter >= 0) {
        return CGSizeMake(_referenceWidthForFooter, self.bounds.size.height);
    }
    CGSize rt = CGSizeMake(0, self.bounds.size.height);
    BOOL left = position == HWTabBarPositionLeft;
    if ([_delegate respondsToSelector:@selector(tabBar:widthForToolItemAtIndex:position:)]) {
        NSInteger count = 0;
        if ([_dataSource respondsToSelector:@selector(numberOfToolItemsInTabBar:position:)]) {
            count = [_dataSource numberOfToolItemsInTabBar:self position:position];
        }
        for (int i = 0; i < count; i++) {
            CGFloat width = [_delegate tabBar:self widthForToolItemAtIndex:i position:position];
            rt.width += width;
            if (left) {
                [_leftToolItemsWidth addObject:@(width)];
            } else {
                [_rightToolItemsWidth addObject:@(width)];
            }
        }
        if (left) {
            _referenceWidthForHeader = rt.width;
        } else {
            _referenceWidthForFooter = rt.width;
        }
    }
    return rt;
}

- (UICollectionReusableView *)callDataSourceToGetToolItemForSupplementaryElementOfKind:(NSString *)kind {
    UICollectionReusableView *rt = nil;

    BOOL left = [kind isEqualToString:UICollectionElementKindSectionHeader];
    HWTabBarPosition position = left ? HWTabBarPositionLeft : HWTabBarPositionRight;
    NSString *reuseId = left ? @"sectionHeader" : @"sectionFooter";
    UICollectionReusableView *section = left ? _sectionHeader : _sectionFooter;
    NSMutableArray<HWTabBarToolItem *> *toolItems = left ? _leftToolItems : _rightToolItems;
    NSMutableArray<NSNumber *> *toolItemsWidth = left ? _leftToolItemsWidth : _rightToolItemsWidth;
    BOOL res = [_dataSource respondsToSelector:@selector(tabBar:toolItemAtIndex:position:)];

    if (section) {
        rt = section;
    } else {
        rt = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseId forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        left ? [self setSectionHeader:rt] : [self setSectionFooter:rt];
        section = rt;
    }
    if (res && toolItems.count <= 0) {
        for (UIView *sub in section.subviews) {
            [sub removeFromSuperview];
        }
        if (toolItemsWidth.count <= 0) {
            [self callDelegateToGetReferenceSizeAtPosition:position];
            toolItemsWidth = left ? _leftToolItemsWidth : _rightToolItemsWidth;
        }
        for (int i = 0; i < toolItemsWidth.count; i++) {
            HWTabBarToolItem *toolItem = [_dataSource tabBar:self toolItemAtIndex:i position:position];
            NSAssert(toolItem, @"tool item can not be nil!!!");
            [section addSubview:toolItem];
            [toolItems addObject:toolItem];
        }
        left ? [self setLeftToolItems:toolItems] : [self setRightToolItems:toolItems];
    }
    return rt;
}

#pragma mark - private

- (void)animationToIndx:(NSInteger)index {
    [_animationView.layer removeAllAnimations];
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (cell && !CGSizeEqualToSize(cell.frame.size, CGSizeZero)) {
        CGRect cellRect = cell.frame;
        CGFloat nextWidth = CGRectGetWidth(cellRect);
        if ([_delegate respondsToSelector:@selector(tabBar:widthForAnimationLineAtIndex:)]) {
            nextWidth = [_delegate tabBar:self widthForAnimationLineAtIndex:index];
        }
        CGRect animationViewRect = _animationView.frame;
        CGFloat animationViewHeight = CGRectGetHeight(animationViewRect);
        __weak typeof(self) ws = self;
        _animationView.frame = CGRectMake(animationViewRect.origin.x,
                                          CGRectGetMaxY(cellRect) - animationViewHeight,
                                          CGRectGetWidth(animationViewRect),
                                          animationViewHeight);
        [UIView animateWithDuration:0.25f
                         animations:^{
                             ws.animationView.bounds = CGRectMake(0, 0, nextWidth, animationViewHeight);
                             ws.animationView.center = CGPointMake(CGRectGetMidX(cellRect),
                                                                   CGRectGetMaxY(cellRect) - animationViewHeight / 2.f);
                         }];
        _animationFailed = NO;
    }
}

#pragma mark - lazy load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (UIView *)animationView {
    if (!_animationView) {
        _animationView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _animationView;
}

@end
