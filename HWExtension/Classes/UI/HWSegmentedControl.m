//
//  HWSegmentedControl.m
//  HWExtension
//
//  Created by houwen.wang on 15/11/5.
//  Copyright © 2015年 houwen.wang. All rights reserved.
//

#import "HWSegmentedControl.h"

// badge
#define kDefaultBadgeImageName (@"product_list_select_icon")        // 默认徽标图片

// color
#define kDefaultAnimationLineColor ([UIColor colorWithHex:0xff5738])         // 默认动画线颜色
#define kDefaultBottomSeparateLineColor ([UIColor colorWithHex:0xeeeeee])    // 默认底部分割线颜色
#define kDefaultVerSeparateLineColor ([UIColor colorWithHex:0x999999])       // 默认item之间垂直分割线线颜色

// item.color
#define kDefaultItemNormalStateTitleColor ([UIColor colorWithHex:0x4c4c4c])       // 默认颜色
#define kDefaultItemHighlightedStateTitleColor ([UIColor colorWithHex:0xff5738])  // 默认高亮颜色
#define kDefaultItemSelectedStateTitleColor ([UIColor colorWithHex:0xff5738])     // 默认选中颜色

// item.font
#define kDefaultItemFont ([UIFont systemFontOfSize:14])   // 默认字体

#pragma mark - HWSegmentedControlItem

@interface HWSegmentedControlItem ()

@property (copy, nonatomic) SelectedAction actionHandler;   // action callback
@property (strong, nonatomic) UIView *verLine;              // 右边缘线
@property (nonatomic, assign) BOOL needUpdateFrame;  //

@end

@implementation HWSegmentedControlItem

+ (instancetype)new {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (self.verLine.superview == nil) {
        self.clipsToBounds = YES;
        [self addSubview:self.verLine];
    }
}

- (void)setActionHandler:(SelectedAction)actionHandler {
    if (_actionHandler != actionHandler) {
        _actionHandler = nil;
        _actionHandler = actionHandler;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<title:%@\n \
            frame:%@\n  \
            verLineHidden:%@\n  \
            verLineAlpha:%@\n  \
            >",
            [self titleForState:UIControlStateNormal],
            [NSValue valueWithCGRect:self.frame],
            @(self.verLine.hidden),
            @(self.verLine.alpha)];
}

#pragma mark - 懒加载

- (UIView *)verLine {
    if (!_verLine) {
        _verLine = [[UIView alloc] init];                         // 宽度默认0.5
        _verLine.backgroundColor = kDefaultVerSeparateLineColor;  // 默认颜色
        _verLine.hidden = YES;
    }
    return _verLine;
}

@end

#pragma mark - HWSegmentedControl

@interface HWSegmentedControl ()

@property (nonatomic, strong) UIScrollView *contentScrollView;    //
@property (nonatomic, strong) UIView *animationLine;              // 底部动画线
@property (nonatomic, strong) UIView *separateLine;               // 底部分割线

@property (nonatomic, strong) NSMutableArray<HWSegmentedControlItem *> *items;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *itemStatesTextColor;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *itemStatesBackgroundColor;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *itemStatesBackgroundImage;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *itemBadgeShowState;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *itemBadgeImage;

@property (nonatomic, assign) BOOL needUpdateFrame;  //

@end

@implementation HWSegmentedControl

@synthesize titles = _titles;

#pragma mark - initialize

+ (instancetype)new {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (self.separateLine.superview == nil) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        _needUpdateFrame = YES;
        _verSepLineHidden = YES;
        _verSepLineColor = kDefaultVerSeparateLineColor;
        _verSepLineEdgeInsets = UIEdgeInsetsZero;
        _verSepLineWidth = 0.5f;
        _verSepLineAlpha = 1.0f;
        
        _minimumInteritemSpacing = CGFLOAT_MAX;
        _selectedIndex = NSUIntegerMax;
        
        [self addSubview:self.contentScrollView];
        [self.contentScrollView addSubview:self.separateLine];
        [self.contentScrollView addSubview:self.animationLine];
    }
}

// 遍历构造初始化
+ (instancetype)segmentedCtrolWithTitles:(NSArray<NSString *> *)titles frame:(CGRect)frame actionHandler:(SelectedAction)handler {
    return [[self alloc] initWithTitles:titles selectedIndex:0 frame:frame actionHandler:handler];
}

// 遍历构造初始化
+ (instancetype)segmentedCtrolWithTitles:(NSArray<NSString *> *)titles selectedIndex:(NSUInteger)selectedIndex frame:(CGRect)frame actionHandler:(SelectedAction)handler {
    return [[self alloc] initWithTitles:titles selectedIndex:selectedIndex frame:frame actionHandler:handler];
}

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles frame:(CGRect)frame actionHandler:(SelectedAction)handler {
    return [self initWithTitles:titles selectedIndex:0 frame:frame actionHandler:handler];
}

// 遍历构造初始化
- (instancetype)initWithTitles:(NSArray<NSString *> *)titles selectedIndex:(NSUInteger)selectedIndex frame:(CGRect)frame actionHandler:(SelectedAction)handler {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        self.titles = titles;
        self.selectedIndex = selectedIndex;
        self.actionhandler = handler;
    }
    return self;
}

#pragma mark - setter

- (void)setActionhandler:(SelectedAction)actionhandler {
    [self setActionhandler:actionhandler executeActionHandler:YES];
}

- (void)setAnimationLineStyle:(HWSegmentedControlAnimationLineStyle)animationLineStyle {
    if (_animationLineStyle != animationLineStyle) {
        _animationLineStyle = animationLineStyle;
        
        self.needUpdateFrame = YES;
        [self setFrame:self.frame];
    }
}

- (void)setItemWidthStyle:(HWSegmentedControlItemWidthStyle)itemWidthStyle {
    if (_itemWidthStyle != itemWidthStyle) {
        _itemWidthStyle = itemWidthStyle;
        
        self.needUpdateFrame = YES;
        [self setFrame:self.frame];
    }
}

- (void)setTitle:(NSString *)title index:(NSUInteger)index {
    if (index < self.items.count) {
        [self.items[index] setTitle:title forState:UIControlStateNormal];
    }
}

- (void)setItemTextFont:(UIFont *)itemTextFont {
    for (HWSegmentedControlItem *item in self.items) {
        item.titleLabel.font = itemTextFont;
    }
    
    self.needUpdateFrame = YES;
    [self setFrame:self.frame];
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    _titles = titles;
    
    if (titles && titles.count) {
        if (titles.count != self.items.count) {
            NSInteger addCount = titles.count - self.items.count;
            for (int i = 0; i < labs(addCount); i++) {
                if (addCount > 0) {
                    [self addItemWithTitle:@"" actionHandler:nil];
                } else {
                    [self.items.lastObject removeFromSuperview];
                    [self.items removeObject:self.items.lastObject];
                }
            }
        }
        
        for (HWSegmentedControlItem *item in self.items) {
            item.actionHandler = nil;
            
            NSString *title = titles[[self.items indexOfObject:item]];
            [item setTitle:title forState:UIControlStateNormal];
        }
    } else {
        for (HWSegmentedControlItem *item in self.items) {
            [item removeFromSuperview];
        }
        [self.items removeAllObjects];
    }
    
    NSUInteger count = titles ? titles.count : 0;
    
    NSUInteger selectedIndex = ((self.selectedIndex < count) ? self.selectedIndex : 0);
    [self setSelectedIndex:selectedIndex executeActionHandler:YES];
    
    self.needUpdateFrame = YES;
    [self setFrame:self.frame];
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    _minimumInteritemSpacing = minimumInteritemSpacing;
    
    self.needUpdateFrame = YES;
    [self setFrame:self.frame];
}

// 选中第几个
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex executeActionHandler:(_selectedIndex != selectedIndex || self.canRepeatExecuteAction)];
}

// 选中第几个, execute: 是否触发 actionhandler
- (void)setSelectedIndex:(NSUInteger)selectedIndex executeActionHandler:(BOOL)execute {
    
    if (selectedIndex < self.items.count) {
        
        if (_selectedIndex < self.items.count) {
            [self.items[_selectedIndex] setSelected:NO];
        }
        [self.items[selectedIndex] setSelected:YES];
        
        CGRect visibleRect = self.items[selectedIndex].frame;
        visibleRect.origin.x -= self.width / 3.0;
        visibleRect.size.width += self.width * 2.0 / 3.0;
        [self.contentScrollView scrollRectToVisible:visibleRect animated:YES];
        
        NSUInteger lastSelectedIndex = self.selectedIndex;
        
        _selectedIndex = selectedIndex;
        
        // 触发回调
        if (execute) {
            [self executeActionHandlerForItem:self.items[selectedIndex] lastSelectedIndex:lastSelectedIndex];
        }
        
        // animationLine
        [self moveAnimationLineToIndex:selectedIndex];
    }
}

//  设置事件回调block, execute: 是否触发 actionhandler
- (void)setActionhandler:(SelectedAction)actionhandler executeActionHandler:(BOOL)execute {
    if (_actionhandler != actionhandler) {
        _actionhandler = nil;
        _actionhandler = actionhandler;
        if (self.items && self.items.count > self.selectedIndex && execute) {
            [self executeActionHandlerForItem:self.items[self.selectedIndex] lastSelectedIndex:self.selectedIndex];
        }
    }
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    self.needUpdateFrame = YES;
    [self setFrame:self.frame];
}

- (void)setNeedsUpdateConstraints {
    [super setNeedsUpdateConstraints];
    self.needUpdateFrame = YES;
    [self setFrame:self.frame];
}

- (void)setFrame:(CGRect)frame {
    
    CGRect originalFrame = self.frame;
    
    [super setFrame:frame];
    
    if (!self.needUpdateFrame) {
        
        if (CGSizeEqualToSize(originalFrame.size, frame.size) ||
            frame.size.width == 0.0f ||
            frame.size.height == 0.0f ||
            self.items == nil ||
            self.items.count == 0) return;
    }
    
    self.needUpdateFrame = NO;
    
    self.contentScrollView.frame = self.bounds;
    
    CGFloat interitemSpacing = 0.0f; // 实际的item间距
    
    // 未设置最小间距
    if (self.minimumInteritemSpacing == CGFLOAT_MAX) {
        interitemSpacing = 20.0; // 默认值
    } else {
        interitemSpacing = self.minimumInteritemSpacing;
    }
    
    NSMutableArray <NSValue *>*itemTextSizeArray = [NSMutableArray array];
    CGFloat totalTextWidth = 0.0;   // 文字总宽度
    for (HWSegmentedControlItem *item in self.items) {
        CGSize itemTextSize = [item.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        [itemTextSizeArray addObject:[NSValue valueWithCGSize:itemTextSize]];
        totalTextWidth += itemTextSize.width;
    }
    
    // 最小需要宽度
    CGFloat minNeedWidth = totalTextWidth + self.items.count * interitemSpacing;
    
    // item是否等宽
    BOOL needEqualWidth = NO;
    
    // 最小需要宽度 > self.width
    if (minNeedWidth > self.width) {
        self.contentScrollView.contentSize = CGSizeMake(minNeedWidth, self.height);
        self.contentScrollView.scrollEnabled = YES;
    } else {
        interitemSpacing = (self.width - totalTextWidth) / self.items.count;
        self.contentScrollView.contentSize = self.size;
        self.contentScrollView.scrollEnabled = NO;
        needEqualWidth = YES;
    }
    
    needEqualWidth = needEqualWidth || (self.itemWidthStyle == HWSegmentedControlItemWidthEqualStyle);
    
    double left = 0.0f;
    CGFloat width = self.width / (self.items.count * 1.0f);
    
    // item
    for (HWSegmentedControlItem *item in self.items) {
        
        NSUInteger index = [self.items indexOfObject:item];
        
        CGSize itemTextSize = itemTextSizeArray[index].CGSizeValue;
        
        CGSize itemBadgeSize = item.currentImage.size;
        if (itemBadgeSize.width >= item.width / 3.0) {
            itemBadgeSize.width = item.width / 3.0;
        }
        
        if (itemBadgeSize.height >= item.height / 2.0) {
            itemBadgeSize.height = item.height / 2.0;
        }
        
        CGFloat topEdge = (item.height - itemTextSize.height) / 2.0;
        CGFloat leftEdge = (item.width + itemTextSize.width) / 2.0 + 8.f;
        
        item.imageEdgeInsets = UIEdgeInsetsMake(topEdge, leftEdge, item.height - topEdge - itemBadgeSize.height,
                                                item.width - leftEdge - itemBadgeSize.width);
        
        if (!needEqualWidth) {
            width = itemTextSize.width + interitemSpacing;
        }
        
        item.frame = CGRectMake(left, 0.0f, width, self.height);
        [self updateVerLineForItem:item];
        
        left = CGRectGetMaxX(item.frame);
    }
    
    // 底部边缘线
    self.separateLine.frame = CGRectMake(0, self.height - self.separateLine.height, self.contentScrollView.contentSize.width, self.separateLine.height);
    
    // animationLine
    [self moveAnimationLineToIndex:self.selectedIndex];
}

#pragma mark getter

- (void)enumerateItems:(HWSegmentedControlEnumeration)enumeration {
    BOOL stop = NO;
    for (HWSegmentedControlItem *item in self.items) {
        NSUInteger index = [self.items indexOfObject:item];
        enumeration(item, index, (index == self.selectedIndex), &stop);
        if (stop) break;
    }
}

- (NSUInteger)count {
    return self.titles ? self.titles.count : 0;
}

- (HWSegmentedControlItem *)itemAtIndex:(NSUInteger)index {
    if (index < self.items.count) {
        return self.items[index];
    }
    return nil;
}

- (NSString *)titleAtIndex:(NSUInteger)index {
    if (index < self.items.count) {
        return self.items[index].titleLabel.text;
    }
    return nil;
}

- (UIFont *)itemTextFont {
    if (self.items && self.items.count) {
        return self.items[0].titleLabel.font;
    }
    return nil;
}

#pragma mark - move animation line

- (void)moveAnimationLineToIndex:(NSUInteger)index {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (index < self.items.count) {
            
            CGFloat width = self.items[index].width;
            if (self.animationLineStyle == HWSegmentedControlAnimationLineWidthEqualTitleStyle) {
                width = [self.items[index].titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].width + 10.0f;
            }
            
            self.animationLine.bottom = self.height;
            self.animationLine.width = width;
            
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.15 animations:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                HWSegmentedControlItem *item = strongSelf.items[index];
                [strongSelf bringSubviewToFront:item];
                strongSelf.animationLine.centerX = item.centerX;
            } completion:nil];
        }
    });
}

#pragma mark - add/remove/insert item

- (void)addItemWithTitle:(NSString *)title actionHandler:(SelectedAction)handler {
    // item
    HWSegmentedControlItem *item = [self itemWithTitle:title actionHandler:handler];
    [self.items addObject:item];
    [self.contentScrollView addSubview:item];
    [self sendSubviewToBack:item];
    
    self.needUpdateFrame = YES;
    [self setFrame:self.frame];
}

- (void)removeItemAtIndex:(NSUInteger)index {
    if (index < self.items.count) {
        HWSegmentedControlItem *item = self.items[index];
        item.actionHandler = nil;
        [item removeFromSuperview];
        [self.items removeObject:item];
        item = nil;
        
        if (index == self.selectedIndex){
            [self setSelectedIndex:0 executeActionHandler:YES];
        }
    }
    
    self.needUpdateFrame = YES;
    [self setFrame:self.frame];
}

- (void)insertItemWithTitle:(NSString *)title index:(NSUInteger)index actionHandler:(SelectedAction)handler {
    if (index <= self.items.count) {
        HWSegmentedControlItem *item = [self itemWithTitle:title actionHandler:handler];
        [self.items insertObject:item atIndex:index];
        [self.contentScrollView addSubview:item];
        
        if (index <= self.selectedIndex) {
            self.selectedIndex += 1;
        }
    }
    
    self.needUpdateFrame = YES;
    [self setFrame:self.frame];
}

#pragma mark badge

- (void)setBadgeImage:(UIImage *)badgeImage index:(NSUInteger)index {
    if (index < self.items.count) {
        if (badgeImage) {
            [self.itemBadgeImage setObject:badgeImage forKey:@(index)];
        } else {
            [self.itemBadgeImage removeObjectForKey:@(index)];
        }
        
        BOOL show = self.itemBadgeShowState[@(index)] ? self.itemBadgeShowState[@(index)].boolValue : NO;
        [self showBadge:show index:index];
    }
}

- (void)showBadge:(BOOL)show index:(NSUInteger)index {
    
    if (index < self.items.count) {
        
        HWSegmentedControlItem *item = self.items[index];
        UIImage *image = nil;
        if (show) {
            image = self.itemBadgeImage[@(index)] ? : [UIImage imageNamed:kDefaultBadgeImageName];
        }
        [item setImage:image forState:UIControlStateNormal];
        self.itemBadgeShowState[@(index)] = @(show);
    }
}

- (void)hideAllBadge {
    for (HWSegmentedControlItem *item in self.items) {
        [item setImage:nil forState:UIControlStateNormal];
    }
}

#pragma mark verSepLine

// verSepLineHidden
- (void)setVerSepLineHidden:(BOOL)verSepLineHidden {
    _verSepLineHidden = verSepLineHidden;
    for (HWSegmentedControlItem *item in self.items) {
        item.verLine.hidden = verSepLineHidden;
    }
}

// verSepLineAlpha
- (void)setVerSepLineAlpha:(CGFloat)verSepLineAlpha {
    _verSepLineAlpha = verSepLineAlpha;
    for (HWSegmentedControlItem *item in self.items) {
        item.verLine.alpha = verSepLineAlpha;
    }
}

// verSepLineColor
- (void)setVerSepLineColor:(UIColor *)verSepLineColor {
    _verSepLineColor = verSepLineColor;
    for (HWSegmentedControlItem *item in self.items) {
        item.verLine.backgroundColor = verSepLineColor;
    }
}

// verSepLineWidth
- (void)setVerSepLineWidth:(CGFloat)verSepLineWidth {
    _verSepLineWidth = verSepLineWidth;
    for (HWSegmentedControlItem *item in self.items) {
        item.verLine.width = verSepLineWidth;
        item.verLine.right = item.width - verSepLineWidth;
    }
}

- (void)setVerSepLineEdgeInsets:(UIEdgeInsets)verSepLineEdgeInsets {
    _verSepLineEdgeInsets = verSepLineEdgeInsets;
    for (HWSegmentedControlItem *item in self.items) {
        item.verLine.top = verSepLineEdgeInsets.top;
        item.verLine.height = self.height - verSepLineEdgeInsets.top - verSepLineEdgeInsets.bottom;
    }
}

#pragma mark set value for state

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    for (HWSegmentedControlItem *item in self.items) {
        [item setTitleColor:color forState:state];
    }
    
    if (!_itemStatesTextColor) {
        _itemStatesTextColor = [NSMutableDictionary dictionary];
    }
    
    color ? [_itemStatesTextColor setObject:color forKey:@(state)] : [_itemStatesTextColor removeObjectForKey:@(state)];
}

// set backgroundColor forState
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    for (HWSegmentedControlItem *item in self.items) {
        [item setBackgroundImage:[UIImage imageWithColor:color] forState:state];
    }
    
    color ? [_itemStatesBackgroundColor setObject:color forKey:@(state)]
    : [_itemStatesBackgroundColor removeObjectForKey:@(state)];
}

// set backgroundImage forState
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    for (HWSegmentedControlItem *item in self.items) {
        [item setBackgroundImage:image forState:state];
    }
    
    image ? [_itemStatesBackgroundImage setObject:image forKey:@(state)]
    : [_itemStatesBackgroundImage removeObjectForKey:@(state)];
}

#pragma mark - lazy load

- (UIScrollView *)contentScrollView {
    if (_contentScrollView == nil) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _contentScrollView;
}

- (UIView *)separateLine {
    if (_separateLine == nil) {
        _separateLine = [[UIView alloc] init];
        _separateLine.backgroundColor = kDefaultBottomSeparateLineColor;
        _separateLine.height = 0.5;
    }
    return _separateLine;
}

- (UIView *)animationLine {
    if (_animationLine == nil) {
        _animationLine = [[UIView alloc] init];
        _animationLine.height = 2.0;
        _animationLine.backgroundColor = kDefaultAnimationLineColor;
    }
    return _animationLine;
}

#pragma mark - private method

// 懒加载
- (NSMutableArray<HWSegmentedControlItem *> *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

// 懒加载
- (NSMutableDictionary<NSNumber *,UIColor *> *)itemStatesBackgroundColor {
    if (!_itemStatesBackgroundColor) {
        _itemStatesBackgroundColor = [NSMutableDictionary dictionary];
    }
    return _itemStatesBackgroundColor;
}

// 懒加载
- (NSMutableDictionary<NSNumber *,UIImage *> *)itemStatesBackgroundImage {
    if (!_itemStatesBackgroundImage) {
        _itemStatesBackgroundImage = [NSMutableDictionary dictionary];
    }
    return _itemStatesBackgroundImage;
}

// 懒加载
- (NSMutableDictionary<NSNumber *,NSNumber *> *)itemBadgeShowState {
    if (!_itemBadgeShowState) {
        _itemBadgeShowState = [NSMutableDictionary dictionary];
    }
    return _itemBadgeShowState;
}

// 懒加载
- (NSMutableDictionary<NSNumber *, UIImage *> *)itemBadgeImage {
    if (!_itemBadgeImage) {
        _itemBadgeImage = [NSMutableDictionary dictionary];
    }
    return _itemBadgeImage;
}

- (void) updateVerLineForItem:(HWSegmentedControlItem *)item {
    if (item) {
        item.verLine.top = self.verSepLineEdgeInsets.top;
        item.verLine.width = self.verSepLineWidth;
        item.verLine.height = self.height - self.verSepLineEdgeInsets.top - self.verSepLineEdgeInsets.bottom;
        item.verLine.right = item.width;
        
        item.verLine.hidden = self.verSepLineHidden;
        item.verLine.backgroundColor = self.verSepLineColor;
        item.verLine.alpha = self.verSepLineAlpha;
    }
}

- (HWSegmentedControlItem *)itemWithTitle:(NSString *)title actionHandler:(SelectedAction)actionhandler {
    
    __block HWSegmentedControlItem *item = [HWSegmentedControlItem buttonWithType:UIButtonTypeCustom];
    
    item.titleLabel.numberOfLines = 0;
    item.actionHandler = actionhandler;
    if (self.itemTextFont == nil) {
        item.titleLabel.font = kDefaultItemFont; // 默认
    } else {
        item.titleLabel.font = self.itemTextFont;
    }
    
    // 默认颜色
    [item setTitleColor:kDefaultItemNormalStateTitleColor forState:UIControlStateNormal];
    [item setTitleColor:kDefaultItemHighlightedStateTitleColor forState:UIControlStateHighlighted];
    [item setTitleColor:kDefaultItemSelectedStateTitleColor forState:UIControlStateSelected];
    
    // title
    [item setTitle:title forState:UIControlStateNormal];
    
    [self updateVerLineForItem:item];
    
    // 已设置的状态颜色
    [_itemStatesTextColor
     enumerateKeysAndObjectsUsingBlock:^(NSNumber *_Nonnull key, UIColor *_Nonnull obj, BOOL *_Nonnull stop) {
         [item setTitleColor:obj forState:key.integerValue];
     }];
    
    // 已设置的状态背景色
    [self.itemStatesBackgroundColor
     enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIColor * _Nonnull obj, BOOL * _Nonnull stop) {
         [item setBackgroundImage:[UIImage imageWithColor:obj] forState:key.unsignedIntegerValue];
     }];
    
    // 已设置的状态背景图片
    [self.itemStatesBackgroundImage
     enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIImage * _Nonnull obj, BOOL * _Nonnull stop) {
         [item setBackgroundImage:obj forState:key.unsignedIntegerValue];
     }];
    
    [item addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return item;
}

- (void)itemClicked:(HWSegmentedControlItem *)sender {
    self.selectedIndex = [self.items indexOfObject:sender];
}

- (void)executeActionHandlerForItem:(HWSegmentedControlItem *)item lastSelectedIndex:(NSUInteger)lastSelectedIndex {
    
    NSUInteger index = ([self.items indexOfObject:item] != NSNotFound) ? [self.items indexOfObject:item] : 0;
    NSUInteger lastIndex = (lastSelectedIndex < self.items.count) ? lastSelectedIndex : 0;
    
    if (self.actionhandler) {
        self.actionhandler(self, item.titleLabel.text, index, lastIndex);
    }
    
    if (item.actionHandler) {
        item.actionHandler(self, item.titleLabel.text, index, lastIndex);
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<titles:%@\n selectedIndex:%@ \n frame:%@>",
            self.titles,
            @(self.selectedIndex),
            [NSValue valueWithCGRect:self.frame]];
}

- (void)dealloc {
}

@end
