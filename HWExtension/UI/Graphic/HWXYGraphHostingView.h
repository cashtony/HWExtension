//
//  HWXYGraphHostingView.h
//  HWExtension
//
//  Created by houwen.wang on 16/8/3.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//
//  曲线图

#import "CorePlot.h"
#import "CPTXYAxis+Category.h"
#import "HWXYGraphInteractionView.h"
#import "HWCategorys.h"

NS_ASSUME_NONNULL_BEGIN

// 无效的数字字符串
BOOL isInvalidNumberString(NSString *str);
#define kIsInvalidNumberString(str) (isInvalidNumberString(str))

// 曲线视图交互状态
typedef NS_ENUM(NSInteger, HWInteractionState) {
    HWUnInteractionState,   // 未交互
    HWInteractioningState   // 交互中
};

// 标注风格
typedef NS_ENUM(NSInteger, HWXYGraphAnnotationStyle) {
    HWXYGraphAnnotationStyleNone,
    HWXYGraphAnnotationStyleBottomLeft,             //
    HWXYGraphAnnotationStyleBottomRight,            //
    HWXYGraphAnnotationStyleTopLeft,                //
    HWXYGraphAnnotationStyleTopRight,               //
    HWXYGraphAnnotationStyleRoundedRectangle        // 圆角矩形
};

@protocol HWXYGraphHostingViewDelegate;

// value
@interface HWXYGraphValue : NSObject <NSCopying, NSMutableCopying>

@property (strong, nonatomic, readonly) NSDecimalNumber *xValue;  //
@property (strong, nonatomic, readonly) NSDecimalNumber *yValue;  //

+ (instancetype)xyValueWithStringX:(nullable NSString *)x stringY:(nullable NSString *)y;

- (BOOL) isEqualToXYValue:(HWXYGraphValue *)xyValue;

@end

@interface HWXYGraphAnnotationInfo : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, copy, readonly) NSAttributedString *text;    //
@property (nonatomic, strong, readonly) UIColor *backgroundColor;  //

+ (instancetype)annotationInfoWithText:(NSAttributedString *)text backgroundColor:(UIColor *)backgroundColor;
@end

// 点
@interface HWXYGraphPoint : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, strong) id userInfo; // 可以用来存储点对应的model信息

@property (nonatomic, strong, readonly) HWXYGraphValue *xyValue;     // x 、y值
@property (nonatomic, strong, readonly) CPTPlotSymbol *plotSymbol;   // 拐点样式
@property (nonatomic, copy, readonly) NSString *xTickLabel;          // X轴刻度标签

// annotation
@property (nonatomic, assign) BOOL showAnnotation;                                   //
// 默认风格, 如果超出边界，会自动被调整, default is HWXYGraphAnnotationStyleBottomRight
@property (nonatomic, assign) HWXYGraphAnnotationStyle defaultAnnotationStyle;
@property (nonatomic, strong, nullable) NSArray <HWXYGraphAnnotationInfo *>*annotationInfos;   //

+ (instancetype)pointWithXYValue:(nullable HWXYGraphValue *)xyValue plotSymbol:(nullable CPTPlotSymbol *)plotSymbol xTickLabel:(nullable NSString *)xTickLabel;

@end

@interface HWXYGraphPoint (PlotSymbol)

- (void)buyPlotSymbol;
- (void)sellPlotSymbol;
- (void)buyAndSellPlotSymbol;

@end

@interface HWXYGraphPoint (Annotation)

- (void)buyAnnotation;
- (void)sellAnnotation;
- (void)buyAndSellAnnotation;

@end

// 曲线范围
@interface HWXYGraphLineRange : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, strong, readonly) HWXYGraphValue *xRange;  //
@property (nonatomic, strong, readonly) HWXYGraphValue *yRange;  //

+ (instancetype)xyGraphLineRangeWithXRange:(HWXYGraphValue *)xRange yRange:(HWXYGraphValue *)yRange;

@end

// 曲线
@interface HWXYGraphLine : NSObject <NSCopying, NSMutableCopying>

@property (strong, nonatomic) NSArray<HWXYGraphPoint *> *points;  // 数据源
@property (copy, nonatomic) NSString *iD;
@property (strong, nonatomic) CPTLineStyle *dataLineStyle;
@property (strong, nonatomic) CPTFill *areaFill;

// 最大回撤
@property (nonatomic, strong, nullable) NSDecimalNumber *maximumDrawdownStart;  // 最大回撤起点
@property (nonatomic, strong, nullable) NSDecimalNumber *maximumDrawdownEnd;    // 最大回撤终点
@property (nonatomic, strong, nullable) UIColor *maximumDrawdownLineColor;      // 最大回撤曲线颜色

- (BOOL)containsXYValue:(HWXYGraphValue *)xyValue;
- (BOOL)containsXYValue:(HWXYGraphValue *)xyValue index:(NSUInteger *)index;

+ (instancetype)lineWithId:(NSString  * _Nullable )iD
                 lineStyle:( CPTLineStyle  * _Nullable )lineStyle
                    points:(NSArray<HWXYGraphPoint *> * _Nullable )points;

@end

@interface HWDirectionRange : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, strong, readonly) NSDecimalNumber *positiveRange;  //
@property (nonatomic, strong, readonly) NSDecimalNumber *negativeRange;  //

+ (instancetype)directionRangeWithPositiveRange:(NSDecimalNumber *)positiveRange negativeRange:(NSDecimalNumber *)negativeRange;
+ (instancetype)directionRangeWithPositiveRangeString:(NSString *)positiveRange negativeRangeString:(NSString *)negativeRange;

- (BOOL) isEqualToDirectionRange:(HWDirectionRange *)otherDirectionRange;

@end

// 画布
@interface HWXYGraphHostingView : CPTGraphHostingView

@property (nonatomic, copy) NSString *nullPointsInfo;  // 图表无数据点时提示信息, default is @"暂无数据"

@property (nonatomic, readwrite, strong, nullable) CPTXYGraph *hostedGraph;

@property (nonatomic, strong, nullable)  CPTPlotRange *defaultXRange;  // 没有数据时x轴的显示范围, default is [0, 24 * 3600]
@property (nonatomic, strong, nullable)  CPTPlotRange *defaultYRange;  // 没有数据时y轴的显示范围, default is [0, 1]

// 一条或多条曲线重叠并且是水平直线时, 正负方向上的 < 扩展幅度 > , default is positiveRange : @(0.1), negativeRange : @(0.1)
@property (nonatomic, strong)  HWDirectionRange *directionRangeWhenLinesNoAmplitude;
@property (nonatomic, assign) UIEdgeInsets plotAreaLayerEdgeInsets;          // 绘图区域的edgeInsets
@property (nonatomic, assign) UIEdgeInsets plotSpaceExpandsRatioEdgeInsets;  // 曲线范围扩展比例 default is UIEdgeInsetsMake(5%, 1.5%, 5%, 3%)

@property (nonatomic, assign) BOOL allowInteraction;                            // 是否支持用户交互 default is YES
@property (nonatomic, strong) NSNumberFormatter *yLabelFormatter;               // y 轴label格式

@property (nonatomic, assign) NSUInteger preferredNumberOfMajorTicksForXAxis;   // x 轴刻度数量, defaule is 3
@property (nonatomic, assign) NSUInteger preferredNumberOfMajorTicksForYAxis;   // y 轴刻度数量, default is 5

@property (nonatomic, assign) CGFloat labelOffsetForXAxis;                      // x轴 刻度值离坐标轴的距离, default is 8.0
@property (nonatomic, assign) CGFloat labelOffsetForYAxis;                      // y轴 刻度值离坐标轴的距离, default is 8.0

@property (nonatomic, assign) NSTextAlignment alignmentForFirstXTickLabel;  // 第一个X轴刻度标签对其方式, default is NSTextAlignmentCenter
@property (nonatomic, assign) NSTextAlignment alignmentForLastXTickLabel;   // 最后一个X轴刻度标签对其方式, default is NSTextAlignmentCenter

// 不需要显示的主刻度网格线下标 , defaule is nil
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *xIgnoreMajorGridLineIndexs;
// 不需要显示的主刻度网格线下标 , defaule is @[@0]
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *yIgnoreMajorGridLineIndexs;

@property (nonatomic, weak) id<HWXYGraphHostingViewDelegate> delegate;  // delagete

@property (nonatomic, copy) NSArray <NSString *>*interactionDateSourceIds;  // 手势交互时数据源的id
@property (nonatomic, assign) BOOL hidesInteractionLineWhenUnInteraction;   // 手势交互结束是否隐藏交互指示线, default is YES
@property (nonatomic, assign) BOOL hidesAnnotationWhenUnInteraction;        // 手势交互结束是否隐藏标注, default is NO, 如果interactionLine隐藏, annotation 一定隐藏

#pragma mark -  添加

// 批量添加
- (void)addLines:(NSArray <HWXYGraphLine *>*)lines;

#pragma mark -  移除

// 批量移除
- (void)removeLinesByIds:(NSArray <NSString *>*)iDs;

// 移除所有
- (void)removeAllLine;

// 所有已添加
- (NSArray<HWXYGraphLine *> *)allLines ;

// 刷新, resetAxisSet : 是否重新计算所有曲线范围，并重新设置坐标范围
- (void)reloadDataWithResetAxisSet:(BOOL)resetAxisSet;

// 更新坐标轴基点
- (void)updateAxisSetOrthogonalPosition;

@end

@protocol HWXYGraphHostingViewDelegate <NSObject>

@optional
- (nullable NSAttributedString *)annotationTextForXYGraphHostingView:(HWXYGraphHostingView *)xyGraphHostingView
                                                              points:(NSArray <HWXYGraphPoint *>*)points
                                                    interactionState:(HWInteractionState)interactionState;

@end

#pragma mark - extension

@interface UIBezierPath (HWXYGraph)

+ (UIBezierPath *)annotationPathWithSize:(CGSize)size            cornerRadius:(CGFloat)radius;
+ (UIBezierPath *)leftTopAnnotationPathWithSize:(CGSize)size     cornerRadius:(CGFloat)radius;
+ (UIBezierPath *)leftBottomAnnotationPathWithSize:(CGSize)size  cornerRadius:(CGFloat)radius;
+ (UIBezierPath *)rightTopAnnotationPathWithSize:(CGSize)size    cornerRadius:(CGFloat)radius;
+ (UIBezierPath *)rightBottomAnnotationPathWithSize:(CGSize)size cornerRadius:(CGFloat)radius;

@end

@interface CPTGradient (HWXYGraph)

+ (CPTGradient *)redGradient;

@end

// 曲线属性
@interface CPTMutableLineStyle (HWXYGraph)

+ (CPTMutableLineStyle *)lineStyleWithColor:(UIColor *)color lineWidth:(CGFloat)lineWidth;

+ (CPTMutableLineStyle *)redLineStyle;
+ (CPTMutableLineStyle *)blueLineStyle;
+ (CPTMutableLineStyle *)yellowLineStyle;

@end

NS_ASSUME_NONNULL_END
