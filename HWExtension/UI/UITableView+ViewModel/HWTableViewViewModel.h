//
//  HWTableViewViewModel.h
//  HWExtension
//
//  Created by houwen.wang on 2016/12/16.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWTableViewDelegate.h"
#import "HWTableViewDataSource.h"

@protocol HWTableViewAdapter <NSObject>

@required

@property (nonatomic, strong, readonly) HWTableViewDelegate *tableViewDelegate;
@property (nonatomic, strong, readonly) HWTableViewDataSource *tableViewDataSource;

@end

@interface HWTableViewViewModel : NSObject<HWTableViewAdapter>

@property (nonatomic, strong, readonly) HWTableViewDelegate *tableViewDelegate;
@property (nonatomic, strong, readonly) HWTableViewDataSource *tableViewDataSource;   

@end
