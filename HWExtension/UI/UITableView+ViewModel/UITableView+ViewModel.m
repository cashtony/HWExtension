//
//  UITableView+ViewModel.m
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/1/18.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import "UITableView+ViewModel.h"

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
