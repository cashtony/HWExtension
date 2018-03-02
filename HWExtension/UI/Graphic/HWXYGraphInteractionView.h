//
//  HWXYGraphInteractionView.h
//  HWExtension
//
//  Created by houwen.wang on 16/8/12.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//
//  曲线交互

#import <UIKit/UIKit.h>
#import "HWCategorys.h"

typedef void (^recognizerHandler)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location);

@interface HWXYGraphInteractionView : UIView

@property (nonatomic, assign) CGRect contentRect;                 //

@property (copy, nonatomic) recognizerHandler recognizerHandler;  // 手势回调block
@property (assign, nonatomic) BOOL showHorizontalLine;            // 是否显示水平线
@property (assign, nonatomic) BOOL showVerticalLine;              // 是否显示垂直线线
@property (assign, nonatomic) CGFloat lineWidth;                  // 水平和垂直线的线宽
@property (strong, nonatomic) UIColor *lineColor;                 // 水平和垂直线的颜色
@property (strong, nonatomic) UIColor *crossLineColor;            // 水平和垂直线交叉点圆圈的颜色
@property (assign, nonatomic) CGFloat crossLineWidth;             // 水平和垂直线交叉点圆圈的线宽
@property (assign, nonatomic) CGSize crossSize;                   // 水平和垂直线交叉点圆圈的size

- (id)initWithFrame:(CGRect)frame recognizerWithHandler:(recognizerHandler)block;  // 初始化

// 显示
- (void)showCrossLineWithPoints:(NSArray <NSValue *>*)points horizontal:(BOOL)horizontal vertical:(BOOL)vertical;

// 隐藏
- (void)hiddenCrossLine;

@end
