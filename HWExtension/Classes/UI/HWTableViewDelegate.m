//
//  HWTableViewDelegate.m
//  HWExtension
//
//  Created by houwen.wang on 2016/12/13.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWTableViewDelegate.h"

@implementation HWTableViewDelegate

// 展示过程回调
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    executeBlock(self.displayCellForRowAtIndexPathCallbackBlock, tableView, cell, indexPath, NO);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0) {
    executeBlock(self.displayCellForRowAtIndexPathCallbackBlock, tableView, cell, indexPath, YES);
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    executeBlock(self.displayHeaderViewOrFooterViewForSectionCallbackBlock, tableView, view, section, YES, NO);
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    executeBlock(self.displayHeaderViewOrFooterViewForSectionCallbackBlock, tableView, view, section, NO, NO);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    executeBlock(self.displayHeaderViewOrFooterViewForSectionCallbackBlock, tableView, view, section, YES, YES);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0) {
    executeBlock(self.displayHeaderViewOrFooterViewForSectionCallbackBlock, tableView, view, section, NO, YES);
}

// 最终展示的尺寸
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    executeReturnValueBlock(self.heightForRowAtIndexPathBlock, 50.0, tableView, indexPath, NO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    executeReturnValueBlock(self.heightForHeaderOrFooterInSectionBlock, 50.0, tableView, section, YES, NO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    executeReturnValueBlock(self.heightForHeaderOrFooterInSectionBlock, 50.0, tableView, section, NO, NO);
}

// 预估尺寸
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
//    executeReturnValueBlock(self.heightForRowAtIndexPathBlock, 50.0, tableView, indexPath, YES);
//}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
//    executeReturnValueBlock(self.heightForHeaderOrFooterInSectionBlock, 0.0, tableView, section, YES, YES);
//}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0) {
//    executeReturnValueBlock(self.heightForHeaderOrFooterInSectionBlock, 0.0, tableView, section, NO, YES);
//}

// 自定义 Section Header
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    executeReturnValueBlock(self.viewForHeaderOrFooterInSectionBlock, nil, tableView, section, YES);
}

// 自定义 Section Footer
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    executeReturnValueBlock(self.viewForHeaderOrFooterInSectionBlock, nil, tableView, section, NO);
}

//// Accessories (disclosures).
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath NS_DEPRECATED_IOS(2_0, 3_0) __TVOS_PROHIBITED {
//    return UITableViewCellAccessoryNone;
//}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    executeBlock(self.accessoryButtonTappedForRowWithIndexPathCallbackBlock, tableView, indexPath);
}

// 选择效果
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    executeReturnValueBlock(self.shouldHighlightRowAtIndexPathBlock, YES, tableView, indexPath);
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    executeBlock(self.highlightOrUnhighlightRowAtIndexPathCallbackBlock, tableView, indexPath, YES);
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
    executeBlock(self.highlightOrUnhighlightRowAtIndexPathCallbackBlock, tableView, indexPath, NO);
}

// 选中、取消选中 过程回调
//- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    return nil;
//}
//
//- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
//    return nil;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    executeBlock(self.selectOrDeselectRowAtIndexPathCallbackBlock, tableView, indexPath, YES);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    executeBlock(self.selectOrDeselectRowAtIndexPathCallbackBlock, tableView, indexPath, NO);
}

// 编辑风格
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    executeReturnValueBlock(self.editingStyleForRowAtIndexPathBlock, UITableViewCellEditingStyleNone, tableView, indexPath);
}

// 删除按钮标题
- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED {
    executeReturnValueBlock(self.titleForDeleteConfirmationButtonForRowAtIndexPathBlock, nil, tableView, indexPath);
}

// 一组编辑操作
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED {
    executeReturnValueBlock(self.editActionsForRowAtIndexPathBlock, nil, tableView, indexPath);
}

// 编辑状态下是否可缩紧
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    executeReturnValueBlock(self.shouldIndentWhileEditingRowAtIndexPathBlock, YES, tableView, indexPath);
}

// 编辑过程回调
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED {
    executeBlock(self.editingRowAtIndexPathCallbackCallbackBlock, tableView, indexPath, NO);
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath __TVOS_PROHIBITED {
    executeBlock(self.editingRowAtIndexPathCallbackCallbackBlock, tableView, indexPath, YES);
}

// 移动、重新排序
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return nil;
}

// 缩进尺寸
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    executeReturnValueBlock(self.indentationLevelForRowAtIndexPathBlock, 0.0, tableView, indexPath);
}

// 拷贝、粘贴 菜单、以下3个代理方法必须都被实现
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(5_0) {
    executeReturnValueBlock(self.shouldShowMenuForRowAtIndexPathBlock, YES, tableView, indexPath);
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
    return YES;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0) {
}

// 焦点
- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0) {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldUpdateFocusInContext:(UITableViewFocusUpdateContext *)context NS_AVAILABLE_IOS(9_0) {
    return YES;
}

- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator NS_AVAILABLE_IOS(9_0) {
}

- (nullable NSIndexPath *)indexPathForPreferredFocusedViewInTableView:(UITableView *)tableView NS_AVAILABLE_IOS(9_0) {
    return nil;
}

@end
