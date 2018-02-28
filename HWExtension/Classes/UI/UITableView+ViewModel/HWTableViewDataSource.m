//
//  HWTableViewDataSource.m
//  HWExtension
//
//  Created by houwen.wang on 2016/12/13.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWTableViewDataSource.h"

@implementation HWTableViewDataSource

#pragma mark - UITableViewDataSource

/*
 * required
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    performReturnValueBlock(self.numberOfRowsInSectionBlock, 0, tableView, section);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    performReturnValueBlock(self.cellForRowAtIndexPathBlock, [UITableViewCell new], tableView, indexPath);
}

/*
 * optional
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    performReturnValueBlock(self.numberOfSectionsBlock, 1, tableView, 0);
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    performReturnValueBlock(self.titleForHeaderOrFooterInSectionBlock, nil, tableView, section, YES);
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    performReturnValueBlock(self.titleForHeaderOrFooterInSectionBlock, nil, tableView, section, NO);
}

// Editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    performReturnValueBlock(self.canEditRowAtIndexPathBlock, NO, tableView, indexPath);
}

// Moving/reordering
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    performReturnValueBlock(self.canMoveRowAtIndexPathBlock, NO, tableView, indexPath);
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    performReturnValueBlock(self.sectionIndexTitlesBlock, nil, tableView);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    performReturnValueBlock(self.sectionForSectionIndexTitleBlock, 0, tableView, title, index);
}

// Data manipulation - insert and delete support
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    performBlock(self.commitEditingRowAtIndexPathHandlerBlock, tableView, editingStyle, indexPath);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    performBlock(self.moveRowAtIndexPathHandlerBlock, tableView,sourceIndexPath, destinationIndexPath);
}

@end
