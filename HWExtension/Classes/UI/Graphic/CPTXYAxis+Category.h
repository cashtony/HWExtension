//
//  CPTXYAxis+Category.h
//  HXXjb
//
//  Created by houwen.wang on 16/8/19.
//  Copyright © 2016年 com.shhxzq. All rights reserved.
//

#import <CorePlot/CorePlot.h>
#import <objc/runtime.h>

@interface CPTXYAxis (Category)

@property (nonatomic, strong) NSArray<NSNumber *> *ignoreMajorGridLineIndexs; // 不需要显示的主刻度网格线下标, default is nil

@end
