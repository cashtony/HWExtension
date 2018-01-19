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
    executeReturnValueBlock(self.numberOfRowsInSectionBlock, 0, tableView, section);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    executeReturnValueBlock(self.cellForRowAtIndexPathBlock, [UITableViewCell new], tableView, indexPath);
}

/*
 * optional
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    executeReturnValueBlock(self.numberOfSectionsBlock, 1, tableView, 0);
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    executeReturnValueBlock(self.titleForHeaderOrFooterInSectionBlock, nil, tableView, section, YES);
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    executeReturnValueBlock(self.titleForHeaderOrFooterInSectionBlock, nil, tableView, section, NO);
}

// Editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    executeReturnValueBlock(self.canEditRowAtIndexPathBlock, NO, tableView, indexPath);
}

// Moving/reordering
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    executeReturnValueBlock(self.canMoveRowAtIndexPathBlock, NO, tableView, indexPath);
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    executeReturnValueBlock(self.sectionIndexTitlesBlock, nil, tableView);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    executeReturnValueBlock(self.sectionForSectionIndexTitleBlock, 0, tableView, title, index);
}

// Data manipulation - insert and delete support
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    executeBlock(self.commitEditingRowAtIndexPathCallbackBlock, tableView, editingStyle, indexPath);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    executeBlock(self.moveRowAtIndexPathCallbackBlock, tableView,sourceIndexPath, destinationIndexPath);
}

@end
