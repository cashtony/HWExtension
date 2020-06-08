//
//  UIButton+Category.h
//  HWExtension
//
//  Created by houwen.wang on 16/6/6.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "NSObject+Category.h"
#import "UIImage+Category.h"

@interface UIButton (Category)

// 使用系统的 titleEdgeInsets、imageEdgeInsets 计算太繁琐，可用以下两个属性设置
@property (nonatomic, assign) CGRect titleRect;  // titleLabel 的位置 （相对于self坐标系）
@property (nonatomic, assign) CGRect imageRect;  // image 的位置（相对于self坐标系）

// 跳转的URL,按钮点击时并不会open url，调用者在按钮回调中可获取到按钮的lingURL属性，调用者自己处理点事件
@property (nonatomic, copy) NSString *linkURL;

@end
