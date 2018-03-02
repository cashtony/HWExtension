//
//  CPTXYAxis+Category.h
//  HWExtension
//
//  Created by houwen.wang on 16/8/19.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "CorePlot.h"
#import "NSObject+Category.h"

@interface CPTXYAxis (Category)

@property (nonatomic, strong) NSArray<NSNumber *> *ignoreMajorGridLineIndexs; // 不需要显示的主刻度网格线下标, default is nil

@end
