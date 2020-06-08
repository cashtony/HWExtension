//
//  HWTabBar.h
//  HWExtension
//
//  Created by Wang,Houwen on 2020/4/7.
//  Copyright © 2020 Wang,Houwen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*                      |<-                       UICollectionView                     ->|
*      ******************************************************************************************************
*      *               |   leftToolItems    |  item  |  item  |  ...  |   rightToolItems   |                |
*      * leftAccessory |  [section header]  | (cell) | (cell) |  ...  |  [section footer]  | rightAccessory |
*      *               |                    |        |        |       |                    |                |
*      ******************************************************************************************************
*/

@protocol HWTabBarDataSource;
@protocol HWTabBarDelegate;

typedef NS_ENUM(NSInteger, HWTabBarScrollPosition) {
    HWTabBarScrollPositionNone = UICollectionViewScrollPositionNone,
    HWTabBarScrollPositionLeft = UICollectionViewScrollPositionLeft,
    HWTabBarScrollPositionCenter = UICollectionViewScrollPositionCenteredHorizontally,
    HWTabBarScrollPositionRight = UICollectionViewScrollPositionRight
};

typedef NS_ENUM(NSInteger, HWTabBarPosition) {
    HWTabBarPositionLeft,
    HWTabBarPositionRight
};

@interface HWTabBar : UIView

@property (nonatomic, strong, nullable) UIColor *animationLineColor;
@property (nonatomic, strong, nullable) UIView *leftAccessoryView;
@property (nonatomic, strong, nullable) UIView *rightAccessoryView;
@property (nonatomic, assign, readonly) NSInteger numberOfItems;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

@property (nonatomic, weak, nullable) id<HWTabBarDataSource> dataSource;
@property (nonatomic, weak, nullable) id<HWTabBarDelegate> delegate;

- (void)reloadData;

- (NSInteger)selectedItemIndex;
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(HWTabBarScrollPosition)scrollPosition;

- (void)registerClass:(nullable Class)itemClass forItemWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableItemWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

@end

@interface HWTabBarToolItem : UIView

@property (nonatomic, strong, readonly) UIButton *button;

@end

@protocol HWTabBarDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInTabBar:(HWTabBar *)tabBar;
- (UICollectionViewCell *)tabBar:(HWTabBar *)tabBar itemAtIndex:(NSInteger)index;

@optional
- (NSInteger)numberOfToolItemsInTabBar:(HWTabBar *)tabBar position:(HWTabBarPosition)position;
- (HWTabBarToolItem *)tabBar:(HWTabBar *)tabBar toolItemAtIndex:(NSInteger)index position:(HWTabBarPosition)position;

@end

@protocol HWTabBarDelegate <NSObject>

@optional
- (CGFloat)tabBar:(HWTabBar *)tabBar widthForItemAtIndex:(NSInteger)index;
- (CGFloat)tabBar:(HWTabBar *)tabBar widthForAnimationLineAtIndex:(NSInteger)index;
- (CGFloat)tabBar:(HWTabBar *)tabBar widthForToolItemAtIndex:(NSInteger)index position:(HWTabBarPosition)position;

- (void)tabBar:(HWTabBar *)tabBar willDisplayItem:(UICollectionViewCell *)item forIndex:(NSInteger)index;
- (void)tabBar:(HWTabBar *)tabBar willDisplayToolItem:(HWTabBarToolItem *)toolItem forIndex:(NSInteger)index position:(HWTabBarPosition)position;

- (void)tabBar:(HWTabBar *)tabBar didSelectItem:(UICollectionViewCell *)item atIndex:(NSInteger)index lastSelectIndex:(NSInteger)lastSelect;
- (void)tabBar:(HWTabBar *)tabBar didSelectToolItem:(HWTabBarToolItem *)toolItem atIndex:(NSInteger)index position:(HWTabBarPosition)position;

@end

NS_ASSUME_NONNULL_END
