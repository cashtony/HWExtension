//
//  HWSegmentedControl.h
//  HWExtension
//
//  Created by houwen.wang on 15/11/5.
//  Copyright © 2015年 houwen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Utils.h"
#import "UIImage+Category.h"
#import "UIColor+Category.h"

@class HWSegmentedControlItem;
@class HWSegmentedControl;

typedef void (^HWSegmentedControlEnumeration)(HWSegmentedControlItem *item, NSUInteger index, BOOL selected, BOOL *stop);
typedef void (^SelectedAction)(HWSegmentedControl *segment, NSString *title, NSUInteger index, NSUInteger lastIndex);

// item width 风格
typedef NS_ENUM(NSInteger, HWSegmentedControlItemWidthStyle) {
    HWSegmentedControlItemTitleGapEqualStyle,   // item.title间隙相等
    HWSegmentedControlItemWidthEqualStyle,      // 每个item 等宽
};

// 动画线风格
typedef NS_ENUM(NSInteger, HWSegmentedControlAnimationLineStyle) {
    HWSegmentedControlAnimationLineWidthEqualTitleStyle,  // 与 title 等宽
    HWSegmentedControlAnimationLineWidthEqualItemStyle,   // 与 item 等宽
};

#pragma mark - HWSegmentedControl

@interface HWSegmentedControl : UIControl

@property (nonatomic, assign) BOOL canRepeatExecuteAction;  // 连续点击相同的index是否可以重复执行block, default is NO

@property (nonatomic, strong) NSArray<NSString *> *titles; // 重新设置所有item,将移除之前所有item
@property (nonatomic, assign, readonly) NSUInteger count;  // 分段数量, always return titles.count
@property (nonatomic, copy) SelectedAction actionhandler;  // action callback

@property (nonatomic, assign) HWSegmentedControlItemWidthStyle itemWidthStyle;  // item宽度风格, default is title gap equal style
@property (nonatomic, assign) HWSegmentedControlAnimationLineStyle animationLineStyle; // 动画线风格, default is width equal title style

@property (nonatomic, strong, readonly) UIView *animationLine; // 底部动画线
@property (nonatomic, strong, readonly) UIView *separateLine;  // 底部分割线

// 选中第几个,default is index 0, 会自动触发actionhandler, if canRepeatExecuteAction == NO, 重复设置相同值不会重复触发actionhandler
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIFont *itemTextFont;            // item 字体, default is [UIFont systemFontOfSize:14]
@property (nonatomic, assign) CGFloat minimumInteritemSpacing; // item最小间距 default is 20.0

//垂直分隔线
@property (nonatomic, assign) BOOL verSepLineHidden;    // 是否隐藏垂直分隔线, default is YES
@property (nonatomic, strong) UIColor *verSepLineColor; // 垂直分隔线颜色

// 垂直分隔线间距（只有top、bottom 有效）default top = 0 && bottom = 0
@property (nonatomic, assign) UIEdgeInsets verSepLineEdgeInsets;
@property (nonatomic, assign) CGFloat verSepLineWidth; // 垂直分隔线宽度 ,default is 0.5
@property (nonatomic, assign) CGFloat verSepLineAlpha; // 垂直分隔线透明度,default is 1.0

#pragma mark - initialize

+ (instancetype)segmentedControlWithTitles:(NSArray<NSString *> *)titles actionHandler:(SelectedAction)handler;
+ (instancetype)segmentedControlWithTitles:(NSArray<NSString *> *)titles selectedIndex:(NSUInteger)index actionHandler:(SelectedAction)handler;
- (instancetype)initWithTitles:(NSArray<NSString *> *)titles actionHandler:(SelectedAction)handler;
- (instancetype)initWithTitles:(NSArray<NSString *> *)titles selectedIndex:(NSUInteger)index actionHandler:(SelectedAction)handler;

// 选中第几个, execute: 是否触发 actionhandler
- (void)setSelectedIndex:(NSUInteger)selectedIndex executeActionHandler:(BOOL)execute;

//  设置事件回调block, execute: 是否触发 actionhandler
- (void)setActionhandler:(SelectedAction)actionhandler executeActionHandler:(BOOL)execute;

#pragma mark - add/remove/insert item

// 添加item
- (void)addItemWithTitle:(NSString *)title actionHandler:(SelectedAction)handler;

// 删除item
- (void)removeItemAtIndex:(NSUInteger)index;

// 插入item
- (void)insertItemWithTitle:(NSString *)title index:(NSUInteger)index actionHandler:(SelectedAction)handler;

// 遍历子控件
- (void)enumerateItems:(HWSegmentedControlEnumeration)enumeration;

#pragma mark - HWSegmentedControlItem at index

- (HWSegmentedControlItem *)itemAtIndex:(NSUInteger)index;

#pragma mark - title at index

// title at index
- (NSString *)titleAtIndex:(NSUInteger)index;

// set title at index
- (void)setTitle:(NSString *)title index:(NSUInteger)index;

#pragma mark - badge at index

// set badge image at index
- (void)setBadgeImage:(UIImage *)badgeImage index:(NSUInteger)index;

// show badge at index
- (void)showBadge:(BOOL)show index:(NSUInteger)index;

// hide all badges
- (void)hideAllBadge;

#pragma mark set value for state

// set titleColor forState
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;

// set backgroundColor forState
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

// set background image forState
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;

@end

#pragma mark - HWSegmentedControlItem

@interface HWSegmentedControlItem : UIButton
@end
