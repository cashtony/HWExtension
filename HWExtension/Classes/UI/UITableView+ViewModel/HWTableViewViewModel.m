//
//  HWTableViewViewModel.m
//  HWExtension
//
//  Created by houwen.wang on 2016/12/16.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWTableViewViewModel.h"

@interface HWTableViewViewModel ()

@property (nonatomic, strong) HWTableViewDelegate *tableViewDelegate;       //
@property (nonatomic, strong) HWTableViewDataSource *tableViewDataSource;   //

@end

@implementation HWTableViewViewModel

- (instancetype)init {
    if (self=[super init]) {
        self.tableViewDelegate = [[HWTableViewDelegate alloc] init];
        self.tableViewDataSource = [[HWTableViewDataSource alloc] init];
    }
    return self;
}

@end
