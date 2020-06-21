//
//  HWGroupViewController.h
//  HWExtension
//
//  Created by Wang,Houwen on 2020/4/7.
//  Copyright © 2020 Wang,Houwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWTabBar.h"
#import "NSIndexPath+HWAdditions.h"
#import "HWGroupViewControllerContent.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HWGroupViewControllerDataSource;
@protocol HWGroupViewControllerDelegate;

typedef NS_ENUM(NSInteger, HWGroupViewControllerBarPosition) {
    HWGroupViewControllerBarPositionGroup,
    HWGroupViewControllerBarPositionPage
};

@interface HWGroupViewControllerBarItem : UICollectionViewCell

@property (nonatomic, strong, readonly) UIButton *contentButton;
@property (nonatomic, strong, readonly) UILabel *badgeLabel;

@end

@interface HWGroupViewController : UIViewController

@property (nonatomic, assign) BOOL enableSwipe; // 是否支持滑动切换tab, default `NO`

@property (nonatomic, strong, nullable) UIImage *backgroundImage;
@property (nonatomic, strong, nullable) UIView *headerView;
@property (nonatomic, strong, readonly) HWTabBar *groupBar;
@property (nonatomic, strong, readonly) HWTabBar *pageBar;
@property (nonatomic, weak, nullable) id<HWGroupViewControllerDataSource> dataSource;
@property (nonatomic, weak, nullable) id<HWGroupViewControllerDelegate> delegate;
- (nullable UIViewController<HWGroupViewControllerContent> *)visibleContent;

@property (nonatomic, assign, readonly) NSInteger numberOfGroups;
- (NSInteger)numberOfPagesInGroup:(NSInteger)group;

- (nullable __kindof UIViewController<HWGroupViewControllerContent> *)dequeueReusableContentWithId:(NSString *)iden;

- (NSIndexPath *)selectedPageAtIndexPath;
- (void)selectPageAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)endRefreshing;

- (void)reloadData;

@end

@protocol HWGroupViewControllerDataSource <NSObject>

@required
- (NSInteger)numberOfGroupsInGroupVC:(HWGroupViewController *)groupVC;
- (NSInteger)groupVC:(HWGroupViewController *)groupVC numberOfPagesInGroup:(NSInteger)group;
- (nonnull UIViewController<HWGroupViewControllerContent> *)groupVC:(HWGroupViewController *)groupVC contentForPageAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)groupVC:(HWGroupViewController *)groupVC numberOfToolItemsAtToolPosition:(HWTabBarPosition)toolPosition barPosition:(HWGroupViewControllerBarPosition)barPosition;
- (HWTabBarToolItem *)groupVC:(HWGroupViewController *)groupVC toolItemAtIndex:(NSInteger)index toolPosition:(HWTabBarPosition)toolPosition barPosition:(HWGroupViewControllerBarPosition)barPosition;

@end

@protocol HWGroupViewControllerDelegate <NSObject>

@optional
/*!
 *  tips : 由于有回弹效果，willDisplayContent回调后不一定回调didDisplayContent
 */
- (void)groupVC:(HWGroupViewController *)groupVC willDisplayContent:(UIViewController<HWGroupViewControllerContent> *)content forPageAtIndexPath:(NSIndexPath *)indexPath;
- (void)groupVC:(HWGroupViewController *)groupVC didDisplayContent:(UIViewController<HWGroupViewControllerContent> *)content forPageAtIndexPath:(NSIndexPath *)indexPath;

- (void)groupVC:(HWGroupViewController *)groupVC willSelectGroup:(NSInteger)group;
- (void)groupVC:(HWGroupViewController *)groupVC didSelectGroup:(NSInteger)group;

- (CGFloat)groupVC:(HWGroupViewController *)groupVC widthForBarItemAtIndex:(NSInteger)index barPosition:(HWGroupViewControllerBarPosition)barPosition;
- (CGFloat)groupVC:(HWGroupViewController *)groupVC widthForBarAnimationLineAtIndex:(NSInteger)index barPosition:(HWGroupViewControllerBarPosition)barPosition;
- (CGFloat)groupVC:(HWGroupViewController *)groupVC widthForBarToolItemAtIndex:(NSInteger)index toolPosition:(HWTabBarPosition)toolPosition barPosition:(HWGroupViewControllerBarPosition)barPosition;

- (void)groupVC:(HWGroupViewController *)groupVC willDisplayBarItem:(HWGroupViewControllerBarItem *)item forIndex:(NSInteger)index barPosition:(HWGroupViewControllerBarPosition)barPosition;
- (void)groupVC:(HWGroupViewController *)groupVC willDisplayBarToolItem:(HWTabBarToolItem *)toolItem forIndex:(NSInteger)index toolPosition:(HWTabBarPosition)toolPosition barPosition:(HWGroupViewControllerBarPosition)barPosition;

- (void)groupVC:(HWGroupViewController *)groupVC didSelectBarToolItem:(HWTabBarToolItem *)toolItem atIndex:(NSInteger)index toolPosition:(HWTabBarPosition)toolPosition barPosition:(HWGroupViewControllerBarPosition)barPosition;

- (void)groupVCBeginRefreshing:(HWGroupViewController *)groupVC;

@end

NS_ASSUME_NONNULL_END
