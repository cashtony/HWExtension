//
//  HWPageViewController.h
//  HWExtension
//
//  Created by Wang,Houwen on 2020/4/6.
//  Copyright © 2020 Wang,Houwen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HWPageViewControllerDataSource;
@protocol HWPageViewControllerDelegate;
@protocol HWPageViewControllerContent;

@interface HWPageViewController : UIViewController

@property (nonatomic, assign, readonly) NSInteger numberOfPages;
@property (nonatomic, weak) id<HWPageViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<HWPageViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;
@property (nonatomic, assign, readonly) UIScrollView *scrollView; // UIPageViewController.scrollView

- (void)reloadData;
- (nullable __kindof UIViewController<HWPageViewControllerContent> *)dequeueReusableContentWithId:(NSString *)iden;
- (nullable UIViewController<HWPageViewControllerContent> *)contentAtPage:(NSInteger)page; // returns nil if content is not visible or page is out of range
- (nullable UIViewController<HWPageViewControllerContent> *)visibleContent;
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;

@end

@protocol HWPageViewControllerDataSource <NSObject>

@required
- (NSInteger)numberOfPagesInPageVC:(HWPageViewController *)pageVC;
- (nonnull UIViewController<HWPageViewControllerContent> *)pageVC:(HWPageViewController *)pageVC contentForPage:(NSInteger)page;

@end

@protocol HWPageViewControllerDelegate <NSObject>

@optional
/*!
 *  tips : UIPageViewController有回弹效果, willDisplayContent回调后不一定回调didDisplayContent
 */
- (void)pageVC:(HWPageViewController *)pageVC willDisplayContent:(UIViewController<HWPageViewControllerContent> *)content forPage:(NSInteger)page;
- (void)pageVC:(HWPageViewController *)pageVC didDisplayContent:(UIViewController<HWPageViewControllerContent> *)content forPage:(NSInteger)page;
- (void)pageVC:(HWPageViewController *)pageVC didEndDisplayingContent:(UIViewController<HWPageViewControllerContent> *)content forPage:(NSInteger)page;

@end

@protocol HWPageViewControllerContent <NSObject>

@optional
@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

- (void)prepareForReuse;
- (void)didEndDisplaying;

@end

NS_ASSUME_NONNULL_END
