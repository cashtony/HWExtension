//
//  HWTableViewBlocks.h
//  HWExtension
//
//  Created by houwen.wang on 2016/12/13.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#ifndef HWTableViewBlocks_h
#define HWTableViewBlocks_h

#import <UIKit/UIKit.h>
#import "NSObject+Category.h"

// com
typedef BOOL (^ConfigEnableBlock)(UITableView *tableView, NSIndexPath *indexPath);

///     UITableViewDataSource blocks

// configs block
typedef UITableViewCell *(^ConfigCellBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef NSInteger (^ConfigNumberBlock)(UITableView *tableView, NSInteger section);
typedef NSString *(^ConfigHeaderOrFooterTitleBlock)(UITableView *tableView, NSInteger section, BOOL isHeader);
typedef NSInteger (^ConfigSectionForSectionIndexTitleBlock)(UITableView *tableView, NSString *sectionIndexTitle, NSInteger atIndex);
typedef NSArray <NSString *>*(^ConfigSectionIndexTitlesBlock)(UITableView *tableView);

// edit handler block
typedef void (^CommitEditingHandlerBlock)(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath);
typedef void (^MoveRowHandlerBlock)(UITableView *tableView, NSIndexPath *sourceIndexPath, NSIndexPath *destinationIndexPath);

///     UITableViewDelegate blocks

// config block
typedef UITableViewCellEditingStyle (^ConfigEditingStyleBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef NSString *(^ConfigDeleteConfirmationButtonTitleBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef CGFloat (^ConfigCellHeightBlock)(UITableView *tableView, NSIndexPath *indexPath, BOOL estimated);
typedef CGFloat (^ConfigCellIndentationLevelBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef CGFloat (^ConfigHeaderOrFooterHeightBlock)(UITableView *tableView, NSInteger section, BOOL isHeader, BOOL estimated);
typedef UIView *(^ConfigHeaderViewOrFooterViewBlock)(UITableView *tableView, NSInteger section, BOOL isHeader);
typedef NSArray<UITableViewRowAction *> *(^ConfigEditActionsBlock)(UITableView *tableView, NSIndexPath *indexPath);

// handler block
typedef void(^DisplayCellHandlerBlock)(UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath, BOOL didEnd);
typedef void(^DisplayHeaderViewOrFooterViewHandlerBlock)(UITableView *tableView, UIView *view, NSInteger section, BOOL isHeader, BOOL didEnd);
typedef void(^SelectOrDeselectRowHandlerBlock)(UITableView *tableView, NSIndexPath *indexPath, BOOL select);
typedef void(^HighlightOrUnhighlightRowHandlerBlock)(UITableView *tableView, NSIndexPath *indexPath, BOOL highlight);
typedef void(^EditingRowHandlerBlock)(UITableView *tableView, NSIndexPath *indexPath, BOOL didEnd);
typedef void(^AccessoryButtonTappedHandlerBlock)(UITableView *tableView, NSIndexPath *indexPath);

#endif /* HWTableViewBlocks_h */
