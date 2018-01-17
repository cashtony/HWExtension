//
//  UITableView+Category.m
//  HWExtension
//
//  Created by houwen.wang on 2016/12/19.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "UITableView+Category.h"

@interface UIView (UITableView)
@property (nonatomic, assign) BOOL _didInitialize_;    //
@end

@implementation UIView (UITableView)

- (BOOL)_didInitialize_ {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)set_didInitialize_:(BOOL)_didInitialize_ {
    objc_setAssociatedObject(self, @selector(_didInitialize_), @(_didInitialize_), OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UITableView (ViewModel)

- (HWTableViewViewModel *)viewModel {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setViewModel:(HWTableViewViewModel *)viewModel {
    if (self.viewModel != viewModel) {
        objc_setAssociatedObject(self, @selector(viewModel), viewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (viewModel) {
            self.delegate = viewModel.tableViewDelegate;
            self.dataSource = viewModel.tableViewDataSource;
        } else {
            self.delegate = nil;
            self.dataSource = nil;
        }
    }
}

@end

@implementation UITableView (Utils)

+ (instancetype)plainStyleTableViewWithFrame:(CGRect)frame delegate:(id<UITableViewDelegate>)delegate dataSource:(id<UITableViewDataSource>)dataSource {
    return [self tableViewWithFrame:frame style:UITableViewStylePlain delegate:delegate dataSource:dataSource];
}

+ (instancetype)groupedStyleTableViewWithFrame:(CGRect)frame delegate:(id<UITableViewDelegate>)delegate dataSource:(id<UITableViewDataSource>)dataSource {
    return [self tableViewWithFrame:frame style:UITableViewStyleGrouped delegate:delegate dataSource:dataSource];
}

+ (instancetype)tableViewWithFrame:(CGRect)frame style:(UITableViewStyle)style delegate:(id<UITableViewDelegate>)delegate dataSource:(id<UITableViewDataSource>)dataSource {
    UITableView *t = [[UITableView alloc] initWithFrame:frame style:style];
    t.delegate = delegate;
    t.dataSource = dataSource;
    return t;
}

/**
 *  @brief 获取重用cell
 *  @param identifier     重用id
 *  @param indexPath      for indexPath
 *  @param nilBlock       未从重用队列中获取到时调用
 *  @param initBlock      初始化block，最多只调用一次
 *  @return cell
 **/
- (nonnull __kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(nullable NSString *)identifier
                                                              indexPath:(NSIndexPath *)indexPath
                                                               nilBlock:(nonnull DequeueCellNilBlock)nilBlock
                                                              initBlock:(nullable CellInitBlock)initBlock {
    
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil && nilBlock) {
        cell = nilBlock(indexPath);
        if (cell && [cell isKindOfClass:[UITableViewCell class]]) {
            [cell setValue:identifier forKey:@"reuseIdentifier"];
        }
    }
    
    if (!cell._didInitialize_ && initBlock) {
        initBlock(cell, indexPath);
        cell._didInitialize_ = YES;
    }
    
    return cell;
}

/**
 *  @brief 获取重用headerFooter
 *  @param identifier           重用id
 *  @param section              for section
 *  @param nilBlock             未从重用队列中获取到时调用
 *  @param initBlock            初始化block，最多只调用一次
 *  @return headerFooter
 **/
- (nonnull __kindof UITableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifier:(nullable NSString *)identifier
                                                                                        section:(NSInteger)section
                                                                                       nilBlock:(nonnull DequeueHeaderFooterNilBlock)nilBlock
                                                                                      initBlock:(nullable HeaderFooterInitBlock)initBlock {
    
    UITableViewHeaderFooterView *headerFooter = [self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    
    if (headerFooter == nil && initBlock) {
        headerFooter = nilBlock(section);
        if (headerFooter && [headerFooter isKindOfClass:[UITableViewHeaderFooterView class]]) {
            [headerFooter setValue:identifier forKey:@"reuseIdentifier"];
        }
    }
    
    if (!headerFooter._didInitialize_ && initBlock) {
        initBlock(headerFooter, section);
        headerFooter._didInitialize_ = YES;
    }
    
    return headerFooter;
}

@end

@implementation UITableView (ContentSize)

- (void)hw_updateContentSize {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL s = NSSelectorFromString(@"_updateContentSize");
    if ([self respondsToSelector:s]) {
        [self performSelector:s];
    }
#pragma clang diagnostic pop
}

@end

@implementation UITableView (Scroll)

- (void)scrollToTopWithAnimated:(BOOL)animated {
    [self setContentOffset:CGPointMake(self.contentOffset.x, 0.0f - self.contentInset.top) animated:animated];
}

- (void)scrollToBottomWithAnimated:(BOOL)animated {
    CGFloat height = self.contentSize.height + self.contentInset.bottom;
    if (height > self.frame.size.height) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, height - self.frame.size.height) animated:animated];
    }
}

@end

