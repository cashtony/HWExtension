//
//  HWXYGraphHostingView.m
//  HWExtension
//
//  Created by houwen.wang on 16/8/3.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWXYGraphHostingView.h"

#define kNillIdPrefix               (@"undefine")
#define kSeparatorSymbol            (@"-")
#define kMaximumDrawdownIdPrefix    (@"maximumDrawdownIdPrefix@")

#define kXValuePerPixel(s) (((self.currentXRange.lengthDouble) * (s)) / self.plotAreaLayerFrame.size.width)
#define kYValuePerPixel(s) (((self.currentYRange.lengthDouble) * (s)) / self.plotAreaLayerFrame.size.height)
#define kPixelPerXValue(s) ((self.plotAreaLayerFrame.size.width * (s)) / (self.currentXRange.lengthDouble))
#define kPixelPerYValue(s) ((self.plotAreaLayerFrame.size.height * (s)) / (self.currentYRange.lengthDouble))

#define kAxisLineWidth        (0.25f)
#define kAxisLineColor        ([[CPTColor colorWithGenericGray:0.6] colorWithAlphaComponent:0.8])

#define kMajorTickLineWidth   (0.25f)
#define kMajorTickLineColor   ([CPTColor blueColor])

#define kMajorGridLineWidth   (0.25f)
#define kMajorGridLineColor   ([[CPTColor colorWithGenericGray:0.6] colorWithAlphaComponent:0.8])

#define kFontSize_h5 (([UIScreen mainScreen].bounds.size.width >= 640) ? 14 : 12)
#define kFontSize_h9 (([UIScreen mainScreen].bounds.size.width >= 640) ? 14 : 12)

#define kNullPointsInfoLabelTextColor           ([UIColor colorWithHex:0xcccccc])  //淡灰
#define kInteractAnnotationBackgroundColor      ([UIColor colorWithHex:0xff5738])
#define kInteractionLineColor                   ([UIColor colorWithHex:0xff5738])
#define kFONT(size) [UIFont systemFontOfSize:size] //获取系统字体，大小为size

@interface HWXYGraphValue ()
@property (strong, nonatomic) NSDecimalNumber *xValue;  //
@property (strong, nonatomic) NSDecimalNumber *yValue;  //
@end

@implementation HWXYGraphValue

+ (instancetype)xyValueWithStringX:(nullable NSString *)x stringY:(nullable NSString *)y {
    HWXYGraphValue *v = [[[self class] alloc] init];
    v.xValue = [NSDecimalNumber decimalNumberWithString:x];
    v.yValue = [NSDecimalNumber decimalNumberWithString:y];
    return v;
}

- (BOOL) isEqualToXYValue:(HWXYGraphValue *)xyValue {
    if (xyValue == nil) {
        return NO;
    }
    return ([self.xValue compare:xyValue.xValue] == NSOrderedSame) && ([self.yValue compare:xyValue.yValue] == NSOrderedSame);
}

- (id)copyWithZone:(NSZone *)zone {
    HWXYGraphValue *copyInstance = [[[self class] allocWithZone:zone] init];
    copyInstance.xValue = [self.xValue copy];
    copyInstance.yValue = [self.yValue copy];
    return copyInstance;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}

- (NSString *)description {
    return [NSString stringWithFormat:@" xValue : %@\n yValue:%@", self.xValue, self.yValue];
}

@end

@interface HWXYGraphAnnotationInfo ()

@property (nonatomic, copy) NSAttributedString *text;       //
@property (nonatomic, strong) UIColor *backgroundColor;     //
@property (nonatomic, strong) CPTPlotSpaceAnnotation *anno;   //

@end

@implementation HWXYGraphAnnotationInfo

+ (instancetype)annotationInfoWithText:(NSAttributedString *)text backgroundColor:(UIColor *)backgroundColor {
    HWXYGraphAnnotationInfo *info = [[[self class] alloc] init];
    info.text = [text copy];
    info.backgroundColor = backgroundColor;
    return info;
}

- (id)copyWithZone:(NSZone *)zone {
    HWXYGraphAnnotationInfo *copyInstance = [[[self class] allocWithZone:zone] init];
    copyInstance.text = [self.text copy];
    copyInstance.backgroundColor = [self.backgroundColor copy];
    copyInstance.anno = self.anno;
    return copyInstance;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}

@end

@interface HWXYGraphPoint ()

@property (nonatomic, assign) BOOL isNaNOfYValue;            // yValue 是否是NaN
@property (nonatomic, strong) HWXYGraphValue *xyValue;       // x 、y值
@property (nonatomic, strong) CPTPlotSymbol *plotSymbol;     // 拐点样式
@property (nonatomic, copy) NSString *xTickLabel;            // X轴刻度标签

@end

@implementation HWXYGraphPoint

- (instancetype)init {
    if (self=[super init]) {
        self.defaultAnnotationStyle = HWXYGraphAnnotationStyleBottomRight;
    }
    return self;
}

+ (instancetype)pointWithXYValue:(nullable HWXYGraphValue *)xyValue plotSymbol:(nullable CPTPlotSymbol *)plotSymbol xTickLabel:(nullable NSString *)xTickLabel {
    HWXYGraphPoint *point = [[[self class] alloc] init];
    point.xyValue = xyValue;
    point.plotSymbol = plotSymbol;
    point.xTickLabel = xTickLabel ? [xTickLabel copy] : nil;
    return point;
}

- (id)copyWithZone:(NSZone *)zone {
    HWXYGraphPoint *copyInstance = [[[self class] allocWithZone:zone] init];
    copyInstance.xyValue = [self.xyValue copy];
    copyInstance.plotSymbol = [self.plotSymbol copy];
    copyInstance.isNaNOfYValue = self.isNaNOfYValue;
    copyInstance.xTickLabel = [self.xTickLabel copy];
    copyInstance.userInfo = self.userInfo;
    
    copyInstance.showAnnotation = self.showAnnotation;
    copyInstance.defaultAnnotationStyle = self.defaultAnnotationStyle;
    copyInstance.annotationInfos = [self.annotationInfos copy];
    return copyInstance;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"xyValue : %@", self.xyValue];
}

@end

@interface HWXYGraphLineRange ()
@property (nonatomic, strong) HWXYGraphValue *xRange;  //
@property (nonatomic, strong) HWXYGraphValue *yRange;  //
@end

@implementation HWXYGraphPoint (PlotSymbol)

- (void)buyPlotSymbol {
    self.plotSymbol = [[self class] customPlotSymbolWithSize:CGSizeMake(6.0f, 6.0f)
                                                   lineWidth:1.0f
                                                   lineColor:[UIColor whiteColor]
                                                        path:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 6, 6) cornerRadius:3]];
    CPTFill *fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor colorWithHex:0xFF7D37].CGColor]];
    self.plotSymbol.fill = fill;
}

- (void)sellPlotSymbol {
    self.plotSymbol = [[self class] customPlotSymbolWithSize:CGSizeMake(6.0f, 6.0f)
                                                   lineWidth:1.0f
                                                   lineColor:[UIColor whiteColor]
                                                        path:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 6, 6) cornerRadius:3]];
    CPTFill *fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor colorWithHex:0x2897FF].CGColor]];
    self.plotSymbol.fill = fill;
}

- (void)buyAndSellPlotSymbol {
    self.plotSymbol = [[self class] customPlotSymbolWithSize:CGSizeMake(6.0f, 6.0f)
                                                   lineWidth:1.0f
                                                   lineColor:[UIColor whiteColor]
                                                        path:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 6, 6) cornerRadius:3]];
    
    UIImage *image1 = [UIImage imageWithColor:[UIColor colorWithHex:0xFF7D37] size:CGSizeMake(5, 5)];
    UIImage *image2 = [UIImage imageWithColor:[UIColor colorWithHex:0x2897FF] size:CGSizeMake(5, 5)];
    UIImage *image =  [UIImage imageOverlyingFromImages:@[@{@1.0 : image1}, @{@1.0 : image2}]];
    
    CPTFill *fill = [CPTFill fillWithImage:[CPTImage imageWithCGImage:image.CGImage]];
    self.plotSymbol.fill = fill;
}

+ (CPTPlotSymbol *)customPlotSymbolWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor path:(UIBezierPath *)path {
    CPTPlotSymbol *plotSymbol = [[CPTPlotSymbol alloc] init];
    plotSymbol.symbolType = CPTPlotSymbolTypeCustom;
    plotSymbol.size = CGSizeMake(6, 6);
    plotSymbol.customSymbolPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 6, 6) cornerRadius:3].CGPath;
    
    CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc] init];
    lineStyle.lineWidth = lineWidth;
    CPTColor *lineColor_t = [CPTColor colorWithCGColor:lineColor.CGColor];
    lineStyle.lineColor = lineColor_t;
    plotSymbol.lineStyle = lineStyle;
    
    return plotSymbol;
}

@end

@implementation HWXYGraphPoint (Annotation)

- (void)buyAnnotation {
    self.showAnnotation = YES;
    self.defaultAnnotationStyle = HWXYGraphAnnotationStyleTopRight;
    self.annotationInfos = @[[HWXYGraphAnnotationInfo annotationInfoWithText:[@"买入"
                                                                              attributedStringWithColor:[UIColor whiteColor]]
                                                             backgroundColor:[UIColor colorWithHex:0xFF7D37]]];
}

- (void)sellAnnotation {
    self.showAnnotation = YES;
    self.defaultAnnotationStyle = HWXYGraphAnnotationStyleBottomLeft;
    self.annotationInfos = @[[HWXYGraphAnnotationInfo annotationInfoWithText:[@"卖出"
                                                                              attributedStringWithColor:[UIColor whiteColor]]
                                                             backgroundColor:[UIColor colorWithHex:0x2897FF]]];
}

- (void)buyAndSellAnnotation {
    self.showAnnotation = YES;
    self.defaultAnnotationStyle = HWXYGraphAnnotationStyleBottomRight;
    self.annotationInfos = @[[HWXYGraphAnnotationInfo annotationInfoWithText:[@"买入"
                                                                              attributedStringWithColor:[UIColor whiteColor]]
                                                             backgroundColor:[UIColor colorWithHex:0xFF7D37]],
                             [HWXYGraphAnnotationInfo annotationInfoWithText:[@"卖出"
                                                                              attributedStringWithColor:[UIColor whiteColor]]
                                                             backgroundColor:[UIColor colorWithHex:0x2897FF]]];
}

@end

@implementation HWXYGraphLineRange

+ (instancetype)xyGraphLineRangeWithXRange:(HWXYGraphValue *)xRange yRange:(HWXYGraphValue *)yRange {
    HWXYGraphLineRange *lineRange = [[[self class] alloc] init];
    lineRange.xRange = xRange;
    lineRange.yRange = yRange;
    return lineRange;
}

- (id)copyWithZone:(NSZone *)zone {
    HWXYGraphLineRange *copyInstance = [[[self class] allocWithZone:zone] init];
    copyInstance.xRange = [self.xRange copy];
    copyInstance.yRange = [self.yRange copy];
    return copyInstance;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}

@end

@interface HWXYGraphLine ()

@property (nonatomic, strong) HWXYGraphLineRange *lineRange;        // 缓存曲线x/y轴范围
@property (nonatomic, strong) HWXYGraphLine *maximumDrawdownLine;   // 最大回撤曲线
@property (nonatomic, assign) NSUInteger startIndex;                // 起点下标
@property (nonatomic, strong) NSMutableSet <CPTPlotSpaceAnnotation *>*annos;    //

@end

@implementation HWXYGraphLine

+ (instancetype)lineWithId:(NSString  * _Nullable )iD
                 lineStyle:( CPTLineStyle  * _Nullable )lineStyle
                    points:(NSArray<HWXYGraphPoint *> * _Nullable )points {
    HWXYGraphLine *line = [[[self class] alloc] init];
    line.iD = iD;
    line.dataLineStyle = lineStyle;
    line.points = points;
    return line;
}

- (NSMutableSet<CPTPlotSpaceAnnotation *> *)annos {
    if (_annos == nil) {
        _annos = [NSMutableSet set];
    }
    return _annos;
}

- (BOOL)containsXYValue:(HWXYGraphValue *)xyValue {
    for (HWXYGraphPoint *p in self.points) {
        if ([p.xyValue isEqualToXYValue:xyValue]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsXYValue:(HWXYGraphValue *)xyValue index:(NSUInteger *)index {
    for (HWXYGraphPoint *p in self.points) {
        if ([p.xyValue isEqualToXYValue:xyValue]) {
            *index = [self.points indexOfObject:p];
            return YES;
        }
    }
    return NO;
}

- (id)copyWithZone:(NSZone *)zone {
    HWXYGraphLine *copyInstance = [[[self class] allocWithZone:zone] init];
    copyInstance.iD = [self.iD copy];
    copyInstance.points = [self.points copy];
    copyInstance.dataLineStyle = [self.dataLineStyle copy];
    copyInstance.areaFill = [self.areaFill copy];
    copyInstance.maximumDrawdownStart = [self.maximumDrawdownStart copy];
    copyInstance.maximumDrawdownEnd = [self.maximumDrawdownEnd copy];
    copyInstance.maximumDrawdownLineColor = [self.maximumDrawdownLineColor copy];
    copyInstance.maximumDrawdownLine = [self.maximumDrawdownLine copy];
    copyInstance.startIndex = self.startIndex;
    copyInstance.lineRange = [self.lineRange copy];
    copyInstance.annos = self.annos;
    return copyInstance;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}

@end

@interface HWDirectionRange ()
@property (nonatomic, strong) NSDecimalNumber *positiveRange;  //
@property (nonatomic, strong) NSDecimalNumber *negativeRange;  //
@end

@implementation HWDirectionRange

+ (instancetype)directionRangeWithPositiveRange:(NSDecimalNumber *)positiveRange negativeRange:(NSDecimalNumber *)negativeRange {
    HWDirectionRange *range = [[[self class] alloc] init];
    range.positiveRange = positiveRange;
    range.negativeRange = negativeRange;
    return range;
}

+ (instancetype)directionRangeWithPositiveRangeString:(NSString *)positiveRange negativeRangeString:(NSString *)negativeRange {
    HWDirectionRange *range = [[[self class] alloc] init];
    range.positiveRange = [NSDecimalNumber decimalNumberWithString:positiveRange];
    range.negativeRange = [NSDecimalNumber decimalNumberWithString:negativeRange];
    return range;
}

- (BOOL) isEqualToDirectionRange:(HWDirectionRange *)otherDirectionRange {
    if (otherDirectionRange == nil) {
        return NO;
    }
    return ([self.positiveRange compare:otherDirectionRange.positiveRange] == NSOrderedSame) && ([self.negativeRange compare:otherDirectionRange.negativeRange] == NSOrderedSame);
}

- (id)copyWithZone:(NSZone *)zone {
    HWDirectionRange *copyInstance = [[[self class] allocWithZone:zone] init];
    copyInstance.positiveRange = [self.positiveRange copy];
    copyInstance.negativeRange = [self.negativeRange copy];
    return copyInstance;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}

@end

@interface HWXYGraphHostingView () <CPTPlotSpaceDelegate,
CPTPlotDataSource,
CPTAxisDelegate,
CPTScatterPlotDelegate,
CPTScatterPlotDataSource>

@property (nonatomic, strong) dispatch_queue_t asynchronizationQueue1;   // 并发队列
@property (nonatomic, strong) dispatch_queue_t asynchronizationQueue2;   // 并发队列

@property (strong, nonatomic) UILabel *nullPointsInfoLabel;             // 图表无数据点时提示信息
@property (strong, nonatomic) NSMutableArray<HWXYGraphLine *> *lines;   // 所有已添加
@property (strong, nonatomic) CPTPlotSpaceAnnotation *interactionAnnotation;       // 交互时浮动气泡
@property (strong, nonatomic) HWXYGraphInteractionView *interactionView;              // 交互View

@property (nonatomic, strong) CPTPlotRange *currentXRange;  //
@property (nonatomic, strong) CPTPlotRange *currentYRange;  //

- (NSUInteger)validLineCount;
- (CPTXYAxisSet *)axisSet;
- (CPTXYPlotSpace *)defaultPlotSpace;

@property (nonatomic, assign) HWXYGraphLine *maxLengthLine;  // 数据最多的line

@end

@implementation HWXYGraphHostingView

@dynamic hostedGraph;

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

// 初始化
- (void)setup {
    
    // 创建并发队列1
    NSString *queueName1 = [NSString stringWithFormat:@"com.HWExtension.%@-%@", NSStringFromClass([self class]), [[NSUUID UUID] UUIDString]];
    self.asynchronizationQueue1 = dispatch_queue_create([queueName1 cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
    
    // 创建并发队列2
    NSString *queueName2 = [NSString stringWithFormat:@"com.HWExtension.%@-%@", NSStringFromClass([self class]), [[NSUUID UUID] UUIDString]];
    self.asynchronizationQueue2 = dispatch_queue_create([queueName2 cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
    
    // 无数据点时提示信息
    [self addSubview:self.nullPointsInfoLabel];
    
    /*  默认数据初始化  */
    if (self.lines == nil) {
        self.lines = [NSMutableArray array];
    }
    
    self.nullPointsInfo = @"暂无数据";
    
    self.hidesInteractionLineWhenUnInteraction = YES;
    self.hidesAnnotationWhenUnInteraction = NO;
    
    self.xIgnoreMajorGridLineIndexs = nil;
    self.yIgnoreMajorGridLineIndexs = @[@0];
    
    // 一条或多条曲线重叠并且是水平直线时, 正负方向上的 < 扩展幅度 >
    self.directionRangeWhenLinesNoAmplitude = [HWDirectionRange directionRangeWithPositiveRangeString:@"0.1" negativeRangeString:@"0.1"];
    
    // 曲线范围扩展比例
    self.plotSpaceExpandsRatioEdgeInsets = UIEdgeInsetsMake(0.05f, 0.015f, 0.05f, 0.03f);
    
    // 没有数据时x轴的显示范围
    self.defaultXRange = [CPTPlotRange plotRangeWithLocation:@(0) length:@(24 * 3600)];
    
    // 没有数据时y轴的显示范围
    self.defaultYRange = [CPTPlotRange plotRangeWithLocation:@(0) length:@(1)];
    
    self.preferredNumberOfMajorTicksForYAxis = 5;
    self.preferredNumberOfMajorTicksForXAxis = 3;
    
    self.alignmentForFirstXTickLabel = NSTextAlignmentCenter;
    self.alignmentForLastXTickLabel = NSTextAlignmentCenter;
    
    self.labelOffsetForXAxis = 8.0; // 刻度值离坐标轴的距离
    self.labelOffsetForYAxis = 8.0; // 刻度值离坐标轴的距离
    [self setupXYGraph];            // 设置图纸
    [self setupAxisSet];            // 设置图纸的坐标轴
    
    self.allowInteraction = YES;    // 默认允许交互
}

// 设置图纸
- (void)setupXYGraph {
    
    self.hostedGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero xScaleType:CPTScaleTypeLinear yScaleType:CPTScaleTypeLinear];
    
    // paddings
    [self setPaddings:UIEdgeInsetsZero forLayer:self.hostedGraph];
    
    self.defaultPlotSpace.allowsMomentum = YES;
    self.defaultPlotSpace.allowsUserInteraction = NO;
    self.currentXRange = self.defaultXRange;
    self.currentYRange = self.defaultYRange;
    
    [self.layer addSublayer:self.hostedGraph];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (self.interactionView) {
        self.interactionView.frame = self.bounds;
        self.interactionView.contentRect = [self plotAreaLayerFrame];
    }
    self.nullPointsInfoLabel.frame = [self plotAreaLayerFrame];
}

// 设置图纸的坐标轴
- (void)setupAxisSet {
    // x
    CPTXYAxis *x = self.axisSet.xAxis;
    [self setupAxis:x];
    x.labelOffset = self.labelOffsetForXAxis;                       // 坐标轴刻度文字位置偏移量
    x.labelingPolicy = CPTAxisLabelingPolicyNone;                   // 刻度线策略
    x.preferredNumberOfMajorTicks = 0;                              // x轴主刻度数量
    x.ignoreMajorGridLineIndexs = self.xIgnoreMajorGridLineIndexs;  // 不显示的主刻度线
    
    // y
    CPTXYAxis *y = self.axisSet.yAxis;
    [self setupAxis:y];
    y.labelOffset = self.labelOffsetForYAxis;                                   // 坐标轴刻度文字位置偏移量
    y.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;                     // 刻度线策略
    y.preferredNumberOfMajorTicks = self.preferredNumberOfMajorTicksForYAxis;   // y轴主刻度数量
    y.ignoreMajorGridLineIndexs = self.yIgnoreMajorGridLineIndexs;              // 不显示的主刻度线
    
    ((CPTMutableLineStyle *)(y.axisLineStyle)).lineWidth = 0.0;        // y轴线不显示
}

- (void)setNullPointsInfo:(NSString *)nullPointsInfo {
    _nullPointsInfo = nullPointsInfo;
    self.nullPointsInfoLabel.text = nullPointsInfo;
}

- (void)setupAxis:(CPTXYAxis *)axis {
    
    // 坐标轴线型
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineColor = kAxisLineColor;
    axisLineStyle.lineWidth = kAxisLineWidth;
    axisLineStyle.miterLimit = kAxisLineWidth;
    
    // 网格线型
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.dashPattern = @[@2, @2];
    majorGridLineStyle.lineColor = kMajorGridLineColor;
    majorGridLineStyle.lineWidth = kMajorGridLineWidth;
    
    // 坐标轴主刻度线型
    CPTMutableLineStyle *majorTickLineStyle = [CPTMutableLineStyle lineStyle];
    majorTickLineStyle.lineColor = kMajorTickLineColor;
    majorTickLineStyle.lineWidth = kMajorTickLineWidth;
    
    // 刻度文字属性
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor colorWithCGColor:[UIColor colorWithHex:0xb5becf].CGColor];
    textStyle.fontName = @"Helvetica Neue";
    textStyle.fontSize = kFontSize_h9 - 2;
    
    axis.axisLineStyle = axisLineStyle;                // 坐标轴线属性
    axis.majorTickLineStyle = majorTickLineStyle;      // 坐标轴主刻度线属性
    axis.labelTextStyle = textStyle;                   // 坐标轴刻度文字属性
    axis.tickDirection = CPTSignNegative;              // 坐标刻度显示方向
    axis.preferredNumberOfMajorTicks = 0;              // 坐标轴主刻度数量
    axis.minorTicksPerInterval = 0;                    // 坐标轴每个主刻度的小刻度数量
    axis.majorTickLength = 0;                          // 坐标轴主刻度线长度
    axis.majorGridLineStyle = majorGridLineStyle;      // 坐标轴主刻度延伸线属性
}

- (void)setYLabelFormatter:(NSNumberFormatter *)yLabelFormatter {
    _yLabelFormatter = yLabelFormatter;
    self.axisSet.yAxis.labelFormatter = yLabelFormatter;
    [self.axisSet.yAxis updateMajorTickLabels];
}

- (void)setPreferredNumberOfMajorTicksForYAxis:(NSUInteger)preferredNumberOfMajorTicksForYAxis {
    _preferredNumberOfMajorTicksForYAxis = preferredNumberOfMajorTicksForYAxis;
    self.axisSet.yAxis.preferredNumberOfMajorTicks = preferredNumberOfMajorTicksForYAxis;
}

- (void)setLabelOffsetForXAxis:(CGFloat)labelOffsetForXAxis {
    _labelOffsetForXAxis = labelOffsetForXAxis;
    self.axisSet.xAxis.labelOffset = labelOffsetForXAxis;
    [self.axisSet.xAxis updateMajorTickLabels];
}

- (void)setLabelOffsetForYAxis:(CGFloat)labelOffsetForYAxis {
    _labelOffsetForYAxis = labelOffsetForYAxis;
    self.axisSet.yAxis.labelOffset = labelOffsetForYAxis;
    [self.axisSet.yAxis updateMajorTickLabels];
}

- (void)setXIgnoreMajorGridLineIndexs:(NSArray<NSNumber *> *)xIgnoreMajorGridLineIndexs {
    if (self.xIgnoreMajorGridLineIndexs != xIgnoreMajorGridLineIndexs) {
        self.axisSet.xAxis.ignoreMajorGridLineIndexs = xIgnoreMajorGridLineIndexs;
    }
}

- (NSArray<NSNumber *> *)xIgnoreMajorGridLineIndexs {
    return self.axisSet.xAxis.ignoreMajorGridLineIndexs;
}

- (void)setYIgnoreMajorGridLineIndexs:(NSArray<NSNumber *> *)yIgnoreMajorGridLineIndexs {
    if (self.yIgnoreMajorGridLineIndexs != yIgnoreMajorGridLineIndexs) {
        self.axisSet.yAxis.ignoreMajorGridLineIndexs = yIgnoreMajorGridLineIndexs;
    }
}

- (NSArray<NSNumber *> *)yIgnoreMajorGridLineIndexs {
    return self.axisSet.yAxis.ignoreMajorGridLineIndexs;
}

- (void)setPlotAreaLayerEdgeInsets:(UIEdgeInsets)plotAreaLayerEdgeInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(self.plotAreaLayerEdgeInsets, plotAreaLayerEdgeInsets) ) {
        [self setPaddings:plotAreaLayerEdgeInsets forLayer:self.plotAreaLayer];
        self.nullPointsInfoLabel.frame = [self plotAreaLayerFrame];
        if (self.interactionView) {
            self.interactionView.contentRect = [self plotAreaLayerFrame];
        }
    }
}

- (UIEdgeInsets)plotAreaLayerEdgeInsets {
    return UIEdgeInsetsMake(self.plotAreaLayer.paddingTop,
                            self.plotAreaLayer.paddingLeft,
                            self.plotAreaLayer.paddingBottom,
                            self.plotAreaLayer.paddingRight);
}

- (void)setPlotSpaceExpandsRatioEdgeInsets:(UIEdgeInsets)plotSpaceExpandsRatioEdgeInsets {
    _plotSpaceExpandsRatioEdgeInsets = plotSpaceExpandsRatioEdgeInsets;
    [self expandRatioEdgeInsets];
}

#pragma mark - public API

#pragma mark - 增、删 line

- (NSArray<HWXYGraphLine *> *)allLines {
    return self.lines;
}

#pragma mark -  添加

// 批量添加
- (void)addLines:(NSArray <HWXYGraphLine *>*)lines {
    
    if (lines == nil || lines.count == 0) {
        return;
    }
    
    NSUInteger maxLength = 0;
    for (HWXYGraphLine *line in lines) {
        __block HWXYGraphLine *tLine = [line copy];
        
        if (tLine.iD == nil || tLine.iD.length == 0) {
            tLine.iD = [NSString stringWithFormat:@"%@%@%@", kNillIdPrefix, kSeparatorSymbol, @(self.lines.count)];
        } else {
            tLine.iD = [NSString stringWithFormat:@"%@%@%@", line.iD, kSeparatorSymbol, @(self.lines.count)];
        }
        
        // 有效的点 & 处理了NaN值
        tLine.points = [self handlerNaNYValuesInPoints:tLine.points];
        
        // 并发计算
        dispatch_async(self.asynchronizationQueue1, ^{
            // x值从小到大排序, 防止x值未排序
            tLine.points = [tLine.points sortedArrayUsingComparator:^NSComparisonResult(HWXYGraphPoint * _Nonnull obj1, HWXYGraphPoint *_Nonnull obj2) {
                return [obj1.xyValue.xValue compare:obj2.xyValue.xValue];
            }];
        });
        
        __weak typeof(self) weakSelf = self;
        dispatch_barrier_sync(self.asynchronizationQueue1, ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.lines addObject:tLine];
        });
        
        maxLength = MAX(maxLength, tLine.points.count);
        if (maxLength == tLine.points.count) {
            self.maxLengthLine = tLine;     // 数据最多的line
        }
    }
}

// 有效的点 & 标记NaN值
- (NSArray <HWXYGraphPoint *>*)handlerNaNYValuesInPoints:(NSArray <HWXYGraphPoint *>*)points {
    // 有效的点
    NSMutableArray <HWXYGraphPoint *>*validPoints = [NSMutableArray array];
    
    if (points && points.count) {
        
        NSArray <HWXYGraphPoint *>*points_t = [points copy]; // copy
        
        for (HWXYGraphPoint *p in points_t) {
            HWXYGraphValue *xyValue = p.xyValue;
            // 有效的点
            if (xyValue &&
                xyValue.xValue &&
                !kIsInvalidNumberString(xyValue.xValue.stringValue)) {
                
                [validPoints addObject:p];
            }
        }
        
        // 有效点数量
        if (validPoints.count) {
            
            NSUInteger nullLength = 0;
            
            for (int i=0; i<validPoints.count; i++) {
                HWXYGraphPoint *p = validPoints[i];
                HWXYGraphValue *xyValue = p.xyValue;
                
                // NaN
                if (kIsInvalidNumberString(xyValue.yValue.stringValue)) {
                    nullLength++;
                    p.isNaNOfYValue = YES;
                } else {
                    if (nullLength > 0) {
                        // 从i=0开始为NaN
                        if (i - nullLength == 0) {
                            
                        } else {
                            NSDecimalNumber *start = validPoints[i-nullLength-1].xyValue.yValue;
                            NSDecimalNumber *end = validPoints[i].xyValue.yValue;
                            NSDecimalNumber *stepLength = [[end decimalNumberBySubtracting:start] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@(nullLength + 1).stringValue]];
                            
                            for (NSInteger j=i-nullLength; j<i; j++) {
                                validPoints[j].xyValue.yValue = [start decimalNumberByAdding:[stepLength decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@(j+1-(i-nullLength)).stringValue]]];
                            }
                        }
                        nullLength = 0;
                    }
                }
            }
        }
    }
    return [[NSArray alloc] initWithArray:validPoints copyItems:YES];
}

#pragma mark -  移除

// 批量移除
- (void)removeLinesByIds:(NSArray <NSString *>*)iDs {
    if (iDs == nil || iDs.count == 0) {
        return;
    }
    
    NSMutableArray <HWXYGraphLine *>*surplus = [NSMutableArray array];
    for (HWXYGraphLine *line in self.lines) {
        NSString *originId = [self originIdForLine:line];
        for (NSString *iD in iDs) {
            if (!([originId isEqualToString:iD] || (iD.length == 0 && [originId isEqualToString:kNillIdPrefix]))) {
                [surplus addObject:line];
            }
        }
    }
    self.lines = surplus;
    [self resetLinesId]; // 重设id
}

// 移除所有
- (void)removeAllLine {
    if (self.lines) {
        [self.lines removeAllObjects];
    }
    [self reloadDataWithResetAxisSet:YES];
}

#pragma mark - reloadData

// 刷新
- (void)reloadDataWithResetAxisSet:(BOOL)resetAxisSet {
    
    // 移除添加的交互线 & 标注
    [self.interactionView hiddenCrossLine];
    [self removeAllAnnotations];
    
    // 移除已添加的曲线
    for (CPTPlot *p in self.hostedGraph.allPlots) {
        [self.hostedGraph removePlot:p];
    }
    
    // 重置x轴刻度
    self.axisSet.xAxis.axisLabels = nil;            // 刻度值
    self.axisSet.xAxis.majorTickLocations = nil;    // 刻度线
    
    // 重置y轴刻度
    self.axisSet.yAxis.axisLabels = nil;            // 刻度值
    self.axisSet.yAxis.majorTickLocations = nil;    // 刻度线
    
    // 是否隐藏空数据文案
    self.nullPointsInfoLabel.hidden = self.validLineCount ? YES : NO;
    
    // 有数据的曲线数量
    if (!self.validLineCount) {
        self.currentXRange = self.defaultXRange;
        self.currentYRange = self.defaultYRange;
    } else {
        // 添加曲线 && 最大回撤
        for (HWXYGraphLine *line in self.lines) {
            [self addPlotForLine:line];
            [self addMaximumDrawdownForLine:line];
        }
        
        // 重新计算所有曲线的范围，并更新坐标范围
        if (resetAxisSet) {
            // x、y轴范围
            CPTPlotRange *xRange;
            CPTPlotRange *yRange;
            [self plotSpaceRangeToFitDataSourceWithXPlotRange:&xRange yPlotRange:&yRange];
            self.currentXRange = xRange;
            self.currentYRange = yRange;
            
            // 曲线范围扩展
            [self expandRatioEdgeInsets];
        }
    }
    // 刷新画板
    [self reloadHostedGraph];
}

// 曲线范围扩展
- (void)expandRatioEdgeInsets {
    
    CPTPlotRange *xRange = [self.currentXRange mutableCopy];
    CPTPlotRange *yRange = [self.currentYRange mutableCopy];
    
    // xRang
    if (xRange.lengthDouble == 0.0f) {
        xRange = [CPTPlotRange plotRangeWithLocation:@(xRange.locationDouble)
                                              length:@(xRange.locationDouble + 1)];
    } else {
        double xMin = xRange.locationDouble;
        double xLength = xRange.lengthDouble;
        xRange = [CPTPlotRange plotRangeWithLocation:@(xMin - xLength * self.plotSpaceExpandsRatioEdgeInsets.left)
                                              length:@(xLength * (1.0f + self.plotSpaceExpandsRatioEdgeInsets.left + self.plotSpaceExpandsRatioEdgeInsets.right))];
    }
    
    // yRang
    if (yRange.lengthDouble == 0.0f) {
        yRange = [CPTPlotRange plotRangeWithLocation:@(yRange.locationDouble - self.directionRangeWhenLinesNoAmplitude.negativeRange.doubleValue) length:@(ABS(self.directionRangeWhenLinesNoAmplitude.positiveRange.doubleValue + self.directionRangeWhenLinesNoAmplitude.negativeRange.doubleValue))];
    } else {
        double yMin = yRange.locationDouble;
        double yLength = yRange.lengthDouble;
        yRange = [CPTPlotRange plotRangeWithLocation:@(yMin - yLength * self.plotSpaceExpandsRatioEdgeInsets.bottom)
                                              length:@(yLength * (1.0f + self.plotSpaceExpandsRatioEdgeInsets.top + self.plotSpaceExpandsRatioEdgeInsets.bottom))];
    }
    
    self.currentXRange = xRange;
    self.currentYRange = yRange;
    
    [self updateAxisSetOrthogonalPosition];
}

// 更新坐标轴基点
- (void)updateAxisSetOrthogonalPosition {
    
    self.axisSet.xAxis.orthogonalPosition = self.currentYRange.location;
    self.axisSet.yAxis.orthogonalPosition = self.currentXRange.location;
    
    for (CPTScatterPlot *p in self.hostedGraph.allPlots) {
        p.areaBaseValue = self.currentYRange.location;
    }
}

// 刷新画板
- (void)reloadHostedGraph {
    [self updateAxisSetOrthogonalPosition];
    [self.axisSet.xAxis updateMajorTickLabels];
    [self.axisSet.yAxis updateMajorTickLabels];
    [self.hostedGraph reloadData];
}

// 根据数据源重设plotspace的range
- (void)plotSpaceRangeToFitDataSourceWithXPlotRange:(CPTPlotRange **)xPlotRange
                                         yPlotRange:(CPTPlotRange **)yPlotRange {
    
    __block NSMutableArray <HWXYGraphLineRange *>*ranges = [NSMutableArray array];
    for (HWXYGraphLine *line in self.lines) {
        if (line.lineRange) {
            [ranges addObject:line.lineRange];
        } else {
            HWXYGraphLineRange *range = [self boundingRangeForLine:line];
            !range ? : [ranges addObject:range];
            line.lineRange = [range copy];  // 缓存计算结果
        }
    }
    
    __block HWXYGraphLineRange *boundingRange = nil;
    dispatch_barrier_sync(self.asynchronizationQueue2, ^{
        for (HWXYGraphLineRange *aRange in ranges) {
            NSUInteger index = [ranges indexOfObject:aRange];
            if (index == 0) {
                boundingRange = [HWXYGraphLineRange xyGraphLineRangeWithXRange:[aRange.xRange copy] yRange:[aRange.yRange copy]];
            } else {
                //                // X
                //                if ([boundingRange.xRange.xValue compare:aRange.xRange.xValue] == NSOrderedDescending) {
                //                    boundingRange.xRange.xValue = [aRange.xRange.xValue copy];
                //                }
                //                if ([boundingRange.xRange.yValue compare:aRange.xRange.yValue] == NSOrderedAscending) {
                //                    boundingRange.xRange.yValue = [aRange.xRange.yValue copy];
                //                }
                
                // Y
                if ([boundingRange.yRange.xValue compare:aRange.yRange.xValue] == NSOrderedDescending) {
                    boundingRange.yRange.xValue = [aRange.yRange.xValue copy];
                }
                if ([boundingRange.yRange.yValue compare:aRange.yRange.yValue] == NSOrderedAscending) {
                    boundingRange.yRange.yValue = [aRange.yRange.yValue copy];
                }
            }
        }
    });
    
    if (boundingRange) {
        // 为了避免x轴时间可能不连续带来的x轴间隔不相等，x轴范围使用数据源数量
        NSInteger maxXLength = 0;
        for (HWXYGraphLine *line in self.lines) {
            maxXLength = MAX(maxXLength, line.points.count);
        }
        boundingRange.xRange.xValue = [NSDecimalNumber decimalNumberWithString:@"0"];
        boundingRange.xRange.yValue =
        [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", @(maxXLength - 1)]];
        
        *xPlotRange = [CPTPlotRange plotRangeWithLocation:boundingRange.xRange.xValue length:[boundingRange.xRange.yValue decimalNumberBySubtracting:boundingRange.xRange.xValue]];
        
        *yPlotRange = [CPTPlotRange plotRangeWithLocation:boundingRange.yRange.xValue length:[boundingRange.yRange.yValue decimalNumberBySubtracting:boundingRange.yRange.xValue]];
    } else {
        *xPlotRange = [CPTPlotRange plotRangeWithLocation:@0 length:@0];
        *yPlotRange = [CPTPlotRange plotRangeWithLocation:@0 length:@0];
    }
}

#pragma mark - CPTScatterPlotDataSource

// 拐点
- (nullable CPTPlotSymbol *)symbolForScatterPlot:(nonnull CPTScatterPlot *)plot recordIndex:(NSUInteger)idx {
    NSArray<HWXYGraphPoint *> *points = [self pointsForPlot:plot];
    if (points && points.count && idx < points.count) {
        return points[idx].plotSymbol;
    }
    return nil;
}

#pragma mark - CPTPlotDataSource

// 数据个数
- (NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot {
    if ([self pointsForPlot:plot]) {
        return [self pointsForPlot:plot].count;
    }
    return 0;
}

// x、y值
- (nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    
    HWXYGraphLine *line = [self lineForPlot:plot];
    NSArray<HWXYGraphPoint *> *points = line.points;
    HWXYGraphPoint *point = points[idx];
    
    if (points && points.count) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            CPTXYAxisSet *axisSet = self.axisSet;  // axisSet
            
            NSNumber *x = @(idx + line.startIndex);
            
            if (![line.iD hasPrefix:kMaximumDrawdownIdPrefix] && [line isEqual:self.maxLengthLine]) {
                if (idx == 0) {
                    axisSet.xAxis.axisLabels = [CPTAxisLabelSet set];
                    axisSet.xAxis.majorTickLocations = [CPTNumberSet set];
                }
                
                // x轴刻度
                if (self.preferredNumberOfMajorTicksForXAxis) {
                    BOOL needAddAxisLabel = NO;
                    if (points.count <= self.preferredNumberOfMajorTicksForXAxis) {
                        needAddAxisLabel = YES;
                    } else {
                        if (self.preferredNumberOfMajorTicksForXAxis == 1) {
                            needAddAxisLabel = (idx == (NSUInteger)(points.count - 1) / 2);
                        } else if (self.preferredNumberOfMajorTicksForXAxis == 2){
                            needAddAxisLabel = (idx == 0 || idx == points.count - 1);
                        } else if (self.preferredNumberOfMajorTicksForXAxis == 3) {
                            needAddAxisLabel = (idx == 0 || idx == points.count - 1 || idx == (NSUInteger)(points.count - 1) / 2);
                        } else {
                            if (idx == 0 || idx == points.count - 1) {
                                needAddAxisLabel = YES;
                            } else {
                                NSUInteger stepLength ;
                                // 余数
                                NSUInteger remainder = (points.count - 1) % (self.preferredNumberOfMajorTicksForXAxis - 1);
                                stepLength = (points.count - 1 + remainder) / (self.preferredNumberOfMajorTicksForXAxis - 1);
                                needAddAxisLabel = (idx % stepLength == 0);
                            }
                        }
                    }
                    
                    if (needAddAxisLabel) {
                        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:point.xTickLabel textStyle:axisSet.xAxis.labelTextStyle];
                        label.tickLocation = x;
                        label.offset = axisSet.xAxis.labelOffset;
                        if (idx == 0 || idx == points.count - 1) {
                            label.alignment = [self cptAlignmentForNSAlignment:(idx == 0 ? self.alignmentForFirstXTickLabel : self.alignmentForLastXTickLabel)];
                        }
                        
                        // 刻度值
                        axisSet.xAxis.axisLabels = [CPTAxisLabelSet setWithArray:[axisSet.xAxis.axisLabels.allObjects arrayByAddingObject:label]];
                        
                        // 刻度线
                        axisSet.xAxis.majorTickLocations = [CPTMutableNumberSet setWithArray:[axisSet.xAxis.majorTickLocations.allObjects arrayByAddingObject:x]];
                    }
                }
            }
            
            if (point.showAnnotation && point.annotationInfos && point.annotationInfos.count && ![line.iD hasPrefix:kMaximumDrawdownIdPrefix]) {
                [self addAnnotationsForPoint:point xValue:[NSDecimalNumber decimalNumberWithString:@(idx).stringValue] forLine:line];
            }
            
            return x;
        } else if (fieldEnum == CPTScatterPlotFieldY) {
            NSDecimalNumber *yValue = point.xyValue.yValue;
            return kIsInvalidNumberString(yValue.stringValue) ? nil : yValue;
        }
    }
    return nil;
}

#pragma mark 用户交互view

- (void)setAllowInteraction:(BOOL)allowInteraction {
    if (allowInteraction) {
        [self addInteractionView];
    } else {
        [self removeInteractionView];
    }
}

// 添加交互view
- (void)addInteractionView {
    if (!self.interactionView) {
        __weak typeof(self) ws = self;
        self.interactionView = [[HWXYGraphInteractionView alloc]
                                initWithFrame:self.bounds
                                interactiveHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                                    __strong typeof(ws) ss = ws;
                                    
                                    if (ss.validLineCount == 0) return;
                                    
                                    NSUInteger maxLength = 0;
                                    for (HWXYGraphLine *line in ss.lines) {
                                        maxLength = MAX(maxLength, line.points.count);
                                    }
                                    
                                    double length = [ss plotAreaLayerFrame].size.width / (maxLength < 2 ? 1.0 : ((maxLength - 1) * 1.0));
                                    NSNumber *num = @((location.x - CGRectGetMinX([self plotAreaLayerFrame])) / length);
                                    NSInteger idx = [ss roundValueWithNumber:num];
                                    
                                    NSUInteger maxIdx = 0;
                                    for (NSString *iD in ss.interactionDateSourceIds) {
                                        
                                        HWXYGraphLine *line = [ss interactionLineForId:iD];
                                        NSArray<HWXYGraphPoint *> *points = line.points;
                                        
                                        if (!points || points.count == 0) continue;
                                        
                                        idx = MAX(idx, 0);
                                        idx = MIN(idx, points.count - 1);
                                        maxIdx = MAX(maxIdx, idx);
                                    }
                                    
                                    NSMutableArray <HWXYGraphPoint *>*callbackPoints = [NSMutableArray array];    // 代理方法回调参数
                                    NSMutableArray <NSValue *>*crossPoints = [NSMutableArray array];            // 交叉点
                                    
                                    for (NSString *iD in ss.interactionDateSourceIds) {
                                        
                                        HWXYGraphLine *line = [ss interactionLineForId:iD];
                                        NSArray<HWXYGraphPoint *> *points = line.points;
                                        
                                        if (maxIdx >= points.count) continue;
                                        
                                        // 交叉点
                                        CGPoint crossPoint = [ss convertPointWithXValue:points[maxIdx].xyValue.xValue atLine:line index:NULL];
                                        points[maxIdx].isNaNOfYValue ? : [crossPoints addObject:[NSValue valueWithCGPoint:crossPoint]];
                                        
                                        // 代理方法回调参数
                                        [callbackPoints addObject:points[maxIdx]];
                                    }
                                    
                                    HWInteractionState interactionState = (state == UIGestureRecognizerStateEnded ||
                                                                           state == UIGestureRecognizerStateCancelled) ? HWUnInteractionState : HWInteractioningState;
                                    
                                    SEL delegateSelector = @selector(annotationTextForXYGraphHostingView:points:interactionState:);
                                    BOOL respondsToSelector = ss.delegate && [ss.delegate respondsToSelector:delegateSelector];
                                    
                                    if (respondsToSelector) {
                                        NSAttributedString *text = [ss.delegate annotationTextForXYGraphHostingView:ss
                                                                                                             points:callbackPoints
                                                                                                   interactionState:interactionState];
                                        
                                        if (text && text.length) {
                                            [ss addInteractAnnotationWithText:text xValue:[NSDecimalNumber
                                                                                           decimalNumberWithString:@(maxIdx).stringValue]];
                                        }
                                    }
                                    
                                    // 手势结束
                                    if (interactionState == HWUnInteractionState) {
                                        if (ss.hidesInteractionLineWhenUnInteraction) {
                                            [ss.interactionView hiddenCrossLine];
                                            [ss removeAnnotation:ss.interactionAnnotation forLine:nil];
                                        } else {
                                            if (ss.hidesAnnotationWhenUnInteraction) {
                                                [ss removeAnnotation:ss.interactionAnnotation forLine:nil];
                                            }
                                        }
                                    } else {
                                        // 添加十字线
                                        [ss.interactionView showCrossLineWithPoints:crossPoints horizontal:NO vertical:YES];
                                        [ss bringSubviewToFront:ss.interactionView];
                                    }
                                }];
        
        self.interactionView.lineWidth = 0.8;
        self.interactionView.lineColor = kInteractionLineColor;
        self.interactionView.crossLineWidth = 1.5;
        self.interactionView.crossLineColor = kInteractionLineColor;
        self.interactionView.crossSize = CGSizeMake(3.0, 3.0);
        self.interactionView.contentRect = [self plotAreaLayerFrame];
    }
    
    if (!self.interactionView.superview) {
        [self addSubview:self.interactionView];
    }
}

// 移除交互view
- (void)removeInteractionView {
    if (self.interactionView) {
        if (self.interactionView.superview) {
            [self.interactionView removeFromSuperview];
        }
        self.interactionView = nil;
    }
}

#pragma mark - private API

#pragma mark - 最大回撤

// 添加最大回撤
- (void)addMaximumDrawdownForLine:(HWXYGraphLine *)line {
    
    // 移除已添加
    [self removeMaximumDrawdownForLine:line];
    
    if (line.maximumDrawdownStart && line.maximumDrawdownEnd) {
        
        NSUInteger startIndex = 0;
        NSUInteger endIndex = 0;
        
        [self convertPointWithXValue:line.maximumDrawdownStart atLine:line index:&startIndex];
        [self convertPointWithXValue:line.maximumDrawdownEnd atLine:line index:&endIndex];
        
        NSString *lineID = [self maximumDrawdownLineIdForLine:line];
        
        //  添加最大回撤曲线
        NSArray<HWXYGraphPoint *> *maximumDrawdownLinePoints = [[line.points subarrayWithRange:NSMakeRange(MIN(startIndex, endIndex), ABS(endIndex - startIndex) + 1)] copy];
        
        CPTMutableLineStyle *lineStyle = [line.dataLineStyle mutableCopy];
        lineStyle.lineColor = [CPTColor colorWithCGColor:line.maximumDrawdownLineColor.CGColor];
        lineStyle.lineWidth = lineStyle.lineWidth + 0.2;
        
        HWXYGraphLine *maximumDrawdownLine = [HWXYGraphLine lineWithId:lineID lineStyle:lineStyle  points:maximumDrawdownLinePoints];
        maximumDrawdownLine.areaFill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[line.maximumDrawdownLineColor colorWithAlphaComponent:0.2].CGColor]];
        maximumDrawdownLine.startIndex = MIN(startIndex, endIndex);
        line.maximumDrawdownLine = maximumDrawdownLine;
        
        // 直接添加最大回撤曲线
        [self addPlotForLine:maximumDrawdownLine];
    }
}

// 移除最大回撤
- (void)removeMaximumDrawdownForLine:(HWXYGraphLine *)line {
    if (line) {
        CPTPlot *plot = [self plotForResetedId:[self maximumDrawdownLineIdForLine:line]];
        [self.hostedGraph removePlot:plot];
    }
}

// 最大回撤曲线ID
- (NSString *)maximumDrawdownLineIdForLine:(HWXYGraphLine *)line {
    NSString *ide = nil;
    if (line && line.iD) {
        ide = [kMaximumDrawdownIdPrefix stringByAppendingString:line.iD];
    }
    return ide;
}

// xyValue 对应的坐标点（相对于画图区域左下角）
- (CGPoint)convertPointWithXValue:(NSDecimalNumber *)xValue atLine:(HWXYGraphLine *)line index:(NSUInteger *)index {
    NSUInteger t_index = 0;
    if ([self containsXValue:xValue inLine:line index:&t_index]) {
        double scale = 10000.00;
        double xFactor = kPixelPerXValue(scale);
        double yFactor = kPixelPerYValue(scale);
        
        double x = (t_index - self.currentXRange.locationDouble) * xFactor / scale;
        double y = (line.points[t_index].xyValue.yValue.doubleValue - self.currentYRange.locationDouble) * yFactor / scale;
        
        if (index != NULL) {
            *index = t_index;
        }
        return CGPointMake(x + CGRectGetMinX([self plotAreaLayerFrame]), y + CGRectGetMinY([self plotAreaLayerFrame]));
    }
    return CGPointZero;
}

- (BOOL)containsXValue:(NSDecimalNumber *)xValue inLine:(HWXYGraphLine *)line index:(NSUInteger *)index {
    for (HWXYGraphPoint *p in line.points) {
        if ([p.xyValue.xValue compare:xValue] == NSOrderedSame) {
            if (index != NULL) {
                *index = [line.points indexOfObject:p];
            }
            return YES;
        }
    }
    return NO;
}

#pragma mark - add / remove plot

// add plot
- (void)addPlotForLine:(HWXYGraphLine *)line {
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
    plot.identifier = line.iD;
    plot.dataLineStyle = line.dataLineStyle;
    plot.areaFill = line.areaFill;
    plot.dataSource = self;
    [self.hostedGraph addPlot:plot toPlotSpace:self.hostedGraph.defaultPlotSpace];
}

#pragma mark - fast getter

// axisSet
- (CPTXYAxisSet *)axisSet {
    if (self.hostedGraph) {
        return (CPTXYAxisSet *)self.hostedGraph.axisSet;
    }
    return nil;
}

// 有数据的曲线数量
- (NSUInteger)validLineCount {
    NSUInteger count = 0;
    for (HWXYGraphLine *line in self.lines) {
        count += (line.points && line.points.count);
    }
    return count;
}

// defaultPlotSpace
- (CPTXYPlotSpace *)defaultPlotSpace {
    if (self.hostedGraph) {
        return (CPTXYPlotSpace *)self.hostedGraph.defaultPlotSpace;
    }
    return nil;
}

#pragma mark - points

// plot 对应的数据源
- (NSArray<HWXYGraphPoint *> *)pointsForPlot:(CPTPlot *)plot {
    HWXYGraphLine *line = [self lineForPlot:plot];
    return line ? line.points : nil;
}

// plot 对应的数据源
- (HWXYGraphLine *)lineForPlot:(CPTPlot *)plot {
    if (plot == nil) {
        return nil;
    }
    if ([plot.identifier isKindOfClass:[NSString class]]) {
        
        NSString *iden = [NSString stringWithString:(NSString *)plot.identifier];
        
        BOOL maximumDrawdownLine = NO;
        if ([iden hasPrefix:kMaximumDrawdownIdPrefix]) {
            iden = [iden substringFromIndex:NSMaxRange([iden rangeOfString:kMaximumDrawdownIdPrefix])];
            maximumDrawdownLine = YES;
        }
        
        NSRange range = [iden rangeOfString:kSeparatorSymbol];
        if (range.length) {
            NSString *idx = [iden substringFromIndex:NSMaxRange(range)];
            if (idx.integerValue < self.lines.count) {
                return maximumDrawdownLine ? self.lines[idx.integerValue].maximumDrawdownLine : self.lines[idx.integerValue];
            }
        }
    }
    return nil;
}

// id 对应的plot
- (CPTPlot *)plotForResetedId:(NSString *)resetedId {
    CPTPlot *plot = nil;
    if (resetedId && resetedId.length) {
        for (CPTPlot *plot in self.hostedGraph.allPlots) {
            if ([plot.identifier isKindOfClass:[NSString class]]) {
                if ([((NSString *)plot.identifier) isEqualToString:resetedId]) {
                    return plot;
                }
            }
        }
    }
    return plot;
}

// 交互时使用的曲线
- (HWXYGraphLine *)interactionLineForId:(NSString *)iD {
    if (![NSString isEmpty:iD] && self.allLines.count){
        for (HWXYGraphLine *line in self.lines) {
            NSString *originId = [self originIdForLine:line];
            if ([originId isEqualToString:iD] && ![originId hasPrefix:kMaximumDrawdownIdPrefix]) {
                return line;
            }
        }
    }
    return nil;
}

// 根据id获取数据源
- (NSArray<HWXYGraphPoint *> *)pointsForOriginId:(NSString *)originId {
    if (originId == nil || ![originId isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString *iden = [NSString stringWithString:originId];
    
    BOOL maximumDrawdownLine = NO;
    if ([iden hasPrefix:kMaximumDrawdownIdPrefix]) {
        iden = [iden substringFromIndex:NSMaxRange([iden rangeOfString:kMaximumDrawdownIdPrefix])];
        maximumDrawdownLine = YES;
    }
    
    for (HWXYGraphLine *line in self.lines) {
        if ([[self originIdForLine:line] isEqualToString:iden]) {
            return maximumDrawdownLine ? line.maximumDrawdownLine.points : line.points;
        }
    }
    return nil;
}


// 将一组point的xyValue放到一个数组中 （xyValue == nil 时将被过滤）
- (NSArray<HWXYGraphValue *> *)xyValuesInPoints:(NSArray<HWXYGraphPoint *> *)points {
    NSMutableArray *xys = [NSMutableArray array];
    for (HWXYGraphPoint *p in points) {
        !p.xyValue ?: [xys addObject:p.xyValue];
    }
    return xys;
}


#pragma mark - bounding range

// 计算曲线的x/y范围
- (HWXYGraphLineRange *)boundingRangeForLine:(HWXYGraphLine *)line {
    
    NSDecimalNumber *minX;
    NSDecimalNumber *maxX;
    NSDecimalNumber *minY;
    NSDecimalNumber *maxY;
    
    for (HWXYGraphPoint *point in line.points) {
        HWXYGraphValue *value = point.xyValue;
        if (value) {
            if (kIsInvalidNumberString(value.xValue.stringValue) || kIsInvalidNumberString(value.yValue.stringValue)) {
                continue;
            }
            if (minX == nil) {
                minX = value.xValue;
                maxX = value.xValue;
                minY = value.yValue;
                maxY = value.yValue;
            } else {
                NSDecimalNumber *xValue = value.xValue;
                NSDecimalNumber *yValue = value.yValue;
                if (xValue && yValue) {
                    // X
                    if ([xValue compare:minX] == NSOrderedAscending) {
                        minX = xValue;
                    } else if ([xValue compare:maxX] == NSOrderedDescending) {
                        maxX = xValue;
                    }
                    
                    // Y
                    if ([yValue compare:minY] == NSOrderedAscending) {
                        minY = yValue;
                    } else if ([yValue compare:maxY] == NSOrderedDescending) {
                        maxY = yValue;
                    }
                }
            }
        }
    }
    
    HWXYGraphLineRange *range = nil;
    
    if (minX) {
        range = [HWXYGraphLineRange xyGraphLineRangeWithXRange:[HWXYGraphValue xyValueWithStringX:minX.stringValue
                                                                                          stringY:maxX.stringValue]
                                                        yRange:[HWXYGraphValue xyValueWithStringX:minY.stringValue
                                                                                          stringY:maxY.stringValue]];
    }
    return range;
}

#pragma mark - line identifier

// 重置plot的id
- (void)resetLinesId {
    if (self.lines == nil || self.lines.count == 0) {
        return;
    }
    for (HWXYGraphLine *line in self.lines) {
        NSUInteger index = [self.lines indexOfObject:line];
        //  重置id
        line.iD = [NSString
                   stringWithFormat:@"%@%@%@", [self originIdForLine:line], kSeparatorSymbol, @(index)];
        //  重置最大回撤id
        line.maximumDrawdownLine.iD = [self maximumDrawdownLineIdForLine:line];
    }
}

// 原始id
- (NSString *)originIdForLine:(HWXYGraphLine *)line {
    NSString *originId = nil;
    if (line != nil) {
        originId = [line.iD substringToIndex:[line.iD rangeOfString:kSeparatorSymbol].location];
    }
    return originId;
}

#pragma mark - plotAreaLayer

// 获取绘图区域rect
- (CGRect)plotAreaLayerFrame {
    CGRect bounds = self.hostedGraph.bounds;
    return CGRectMake(self.plotAreaLayer.paddingLeft, self.plotAreaLayer.paddingBottom,
                      bounds.size.width - self.plotAreaLayer.paddingLeft - self.plotAreaLayer.paddingRight,
                      bounds.size.height - self.plotAreaLayer.paddingTop - self.plotAreaLayer.paddingBottom);
}

// 绘图区域layer
- (CPTPlotAreaFrame *)plotAreaLayer {
    if (self.hostedGraph) {
        return self.hostedGraph.plotAreaFrame;
    }
    return nil;
}

- (void)setPaddings:(UIEdgeInsets)paddings forLayer:(CPTLayer *)layer {
    layer.paddingTop = paddings.top;
    layer.paddingLeft = paddings.left;
    layer.paddingBottom = paddings.bottom;
    layer.paddingRight = paddings.right;
}

#pragma mark - plotSpace.rang


// x 轴范围
- (CPTPlotRange *)currentXRange {
    if (self.defaultPlotSpace) {
        return self.defaultPlotSpace.xRange;
    }
    return nil;
}

// x 轴范围
- (void)setCurrentXRange:(CPTPlotRange *)currentXRange {
    if (self.defaultPlotSpace && currentXRange) {
        self.defaultPlotSpace.xRange = currentXRange;
    }
}

// y 轴范围
- (CPTPlotRange *)currentYRange {
    if (self.defaultPlotSpace) {
        return self.defaultPlotSpace.yRange;
    }
    return nil;
}

// y 轴范围
- (void)setCurrentYRange:(CPTPlotRange *)currentYRange {
    if (self.defaultPlotSpace && currentYRange) {
        self.defaultPlotSpace.yRange = currentYRange;
    }
}

#pragma mark - annotation

- (void)addInteractAnnotationWithText:(NSAttributedString *)text xValue:(NSDecimalNumber *)xValue {
    HWXYGraphAnnotationInfo *info = [HWXYGraphAnnotationInfo annotationInfoWithText:text
                                                                    backgroundColor:kInteractAnnotationBackgroundColor];
    info.anno = self.interactionAnnotation;
    [self addAnnotations:@[info]
                 xyValue:[HWXYGraphValue xyValueWithStringX:xValue.stringValue stringY:@(MAXFLOAT).stringValue]
                  offset:CGPointZero
            defaultstyle:HWXYGraphAnnotationStyleNone
                 forLine:nil];
}

- (void)addAnnotationsForPoint:(HWXYGraphPoint *)point xValue:(NSDecimalNumber *)xValue forLine:(HWXYGraphLine *)line {
    
    if (point == nil) return;
    
    for (HWXYGraphAnnotationInfo *info in point.annotationInfos) {
        CPTPlotSpaceAnnotation *anno = [self annotation];
        info.anno = anno;
    }
    
    [self addAnnotations:point.annotationInfos
                 xyValue:[HWXYGraphValue xyValueWithStringX:xValue.stringValue stringY:point.xyValue.yValue.stringValue]
                  offset:CGPointMake(0, point.plotSymbol.size.height / 2.0f)
            defaultstyle:point.defaultAnnotationStyle
                 forLine:line];
}

- (void)addAnnotations:(NSArray <HWXYGraphAnnotationInfo *>*)annos
               xyValue:(HWXYGraphValue *)xyValue
                offset:(CGPoint)offset
          defaultstyle:(HWXYGraphAnnotationStyle)defaultstyle
               forLine:(HWXYGraphLine *)line {
    
    CGSize boxSize = CGSizeZero;
    CGSize baseSize = CGSizeZero;
    
    for (HWXYGraphAnnotationInfo *info in annos) {
        
        NSUInteger index = [annos indexOfObject:info];
        
        if (info.anno && info.text && info.text.length) {
            
            // config
            [self configureAnnotation:info.anno text:info.text bgColor:info.backgroundColor];
            
            CGSize size_t = info.anno.contentLayer.frame.size;
            
            size_t.width += 2.0f;
            size_t.height += ((index == 0 && defaultstyle != HWXYGraphAnnotationStyleRoundedRectangle &&
                               defaultstyle != HWXYGraphAnnotationStyleNone) ? 6.0f : 2.0f);
            
            boxSize.height += (size_t.height + 2.0f);
            boxSize.width = MAX(boxSize.width, size_t.width);
            
            if (index == 0) {
                baseSize = size_t;
            }
            
            // 添加
            [self addAnnotation:info.anno forLine:line];
        }
    }
    
    if (!CGSizeEqualToSize(boxSize, CGSizeZero)) {
        [self sizeToFitForAnnotations:annos xyValue:xyValue boxSize:boxSize offset:offset baseSize:baseSize defaultstyle:defaultstyle];
    }
}

- (void)sizeToFitForAnnotations:(NSArray <HWXYGraphAnnotationInfo *>*)annos
                        xyValue:(HWXYGraphValue *)xyValue
                        boxSize:(CGSize)boxSize
                         offset:(CGPoint)offset
                       baseSize:(CGSize)baseSize
                   defaultstyle:(HWXYGraphAnnotationStyle)defaultstyle {
    
    if (annos) {
        double xValuePerPixel = kXValuePerPixel(1.0f);
        double yValuePerPixel = kYValuePerPixel(1.0f);
        
        HWXYGraphAnnotationStyle style = [self annotationStyleThatFitsBoxSize:boxSize
                                                                       offset:offset
                                                                     baseSize:baseSize
                                                                      xyValue:xyValue
                                                                 defaultstyle:defaultstyle];
        
        double yAnchor = xyValue.yValue.doubleValue;
        
        double minXAnchor = self.currentXRange.locationDouble + boxSize.width * 0.5f * xValuePerPixel;
        double maxXAnchor = self.currentXRange.endDouble - boxSize.width * 0.5f * xValuePerPixel;
        double minYAnchor = self.currentYRange.locationDouble + boxSize.height * 0.5f * yValuePerPixel;
        double maxYAnchor = self.currentYRange.endDouble + (self.plotAreaLayerEdgeInsets.top - boxSize.height * 0.5f) * yValuePerPixel;
        
        for (HWXYGraphAnnotationInfo *info in annos) {
            
            NSUInteger index = [annos indexOfObject:info];
            double xAnchor = xyValue.xValue.doubleValue;
            
            NSInteger directionX = 0;
            NSInteger directionY = 0;
            
            if (style == HWXYGraphAnnotationStyleBottomLeft) {
                directionX = 1;
                directionY = 1;
            } else if (style == HWXYGraphAnnotationStyleBottomRight) {
                directionX = -1;
                directionY = 1;
            } else if (style == HWXYGraphAnnotationStyleTopLeft) {
                directionX = 1;
                directionY = -1;
            } else if (style == HWXYGraphAnnotationStyleTopRight) {
                directionX = -1;
                directionY = -1;
            } else if (style == HWXYGraphAnnotationStyleRoundedRectangle) {
                directionX = 0;
                directionY = 1;
            }
            
            CGFloat paddingTop = 1 + (directionY < 0 ? 1 : 0) * (4 * ABS(directionY)) * (index == 0 ? 1 : 0) * ((style ==
                                                                                                                 HWXYGraphAnnotationStyleRoundedRectangle ||
                                                                                                                 style ==
                                                                                                                 HWXYGraphAnnotationStyleRoundedRectangle) ? 0 : 1);
            
            CGFloat paddingBottom = 1 + (directionY < 0 ? 0 : 1) * (4 * ABS(directionY)) * (index == 0 ? 1 : 0) *((style ==
                                                                                                                   HWXYGraphAnnotationStyleRoundedRectangle ||
                                                                                                                   style ==
                                                                                                                   HWXYGraphAnnotationStyleRoundedRectangle) ? 0 : 1);
            
            UIEdgeInsets paddings = UIEdgeInsetsMake(paddingTop, 1, paddingBottom, 1);
            [self setPaddings:paddings forLayer:info.anno.contentLayer];
            CGSize size_t = info.anno.contentLayer.frame.size;
            
            xAnchor += (xValuePerPixel * (size_t.width * 0.5f + offset.x) * directionX);
            
            if (index == 0) {
                yAnchor += (yValuePerPixel * (size_t.height * 0.5f + offset.y + 2.0f) * directionY);
            } else {
                yAnchor += (yValuePerPixel * (size_t.height + 4.0f) * directionY);
            }
            
            xAnchor = MAX(minXAnchor, xAnchor);
            xAnchor = MIN(maxXAnchor, xAnchor);
            
            yAnchor = MAX(minYAnchor, yAnchor);
            yAnchor = MIN(maxYAnchor, yAnchor);
            
            info.anno.anchorPlotPoint = @[@(xAnchor), @(yAnchor)];
            
            // clips
            if (style != HWXYGraphAnnotationStyleNone) {
                if (index == 0) {
                    if (style == HWXYGraphAnnotationStyleBottomLeft) {
                        [self clipsAnnotation:info.anno path:[UIBezierPath leftBottomAnnotationPathWithSize:size_t cornerRadius:3]];
                    } else if (style == HWXYGraphAnnotationStyleBottomRight) {
                        [self clipsAnnotation:info.anno path:[UIBezierPath rightBottomAnnotationPathWithSize:size_t cornerRadius:3]];
                    } else if (style == HWXYGraphAnnotationStyleTopLeft) {
                        [self clipsAnnotation:info.anno path:[UIBezierPath leftTopAnnotationPathWithSize:size_t cornerRadius:3]];
                    } else if (style == HWXYGraphAnnotationStyleTopRight) {
                        [self clipsAnnotation:info.anno path:[UIBezierPath rightTopAnnotationPathWithSize:size_t cornerRadius:3]];
                    } else if (style == HWXYGraphAnnotationStyleRoundedRectangle) {
                        [self clipsAnnotation:info.anno path:[UIBezierPath annotationPathWithSize:size_t cornerRadius:3]];
                    }
                } else {
                    [self clipsAnnotation:info.anno path:[UIBezierPath annotationPathWithSize:size_t cornerRadius:3]];
                }
            }
        }
    }
}

- (HWXYGraphAnnotationStyle)annotationStyleThatFitsBoxSize:(CGSize)boxSize
                                                    offset:(CGPoint)offset
                                                  baseSize:(CGSize)baseSize
                                                   xyValue:(HWXYGraphValue *)xyValue
                                              defaultstyle:(HWXYGraphAnnotationStyle)defaultstyle {
    
    double xValuePerPixel = kXValuePerPixel(1.0f);
    double yValuePerPixel = kYValuePerPixel(1.0f);
    
    double x = baseSize.width * 0.5f * xValuePerPixel;
    double y = (baseSize.height * 0.5f + boxSize.height) * yValuePerPixel;
    
    double xOffset = offset.x * xValuePerPixel;
    double yOffset = offset.x * yValuePerPixel;
    
    double minX = self.currentXRange.locationDouble;
    double maxX = self.currentXRange.endDouble;
    
    double minY = self.currentYRange.locationDouble;
    double maxY = self.currentYRange.endDouble;
    
    BOOL left = NO, bottom = NO;
    
    switch (defaultstyle) {
            
        case HWXYGraphAnnotationStyleBottomLeft: {
            left = (xyValue.xValue.doubleValue + x + xOffset > maxX) ? NO : YES;
            bottom = (xyValue.yValue.doubleValue + y + yOffset > maxY) ? NO : YES;
        } break;
            
        case HWXYGraphAnnotationStyleBottomRight: {
            left = (xyValue.xValue.doubleValue - x - xOffset < minX) ? YES : NO;
            bottom = (xyValue.yValue.doubleValue + y + yOffset > maxY) ? NO : YES;
        } break;
            
        case HWXYGraphAnnotationStyleTopLeft: {
            left = (xyValue.xValue.doubleValue + x + xOffset > maxX) ? NO : YES;
            bottom = (xyValue.yValue.doubleValue - y - yOffset < minY) ? YES : NO;
        } break;
            
        case HWXYGraphAnnotationStyleTopRight: {
            left = (xyValue.xValue.doubleValue - x - xOffset< minX) ? YES : NO;
            bottom = (xyValue.yValue.doubleValue - y - yOffset < minY) ? YES : NO;
        } break;
            
        case HWXYGraphAnnotationStyleNone:
        case HWXYGraphAnnotationStyleRoundedRectangle: {
            return defaultstyle;
        } break;
            
        default: {
            return defaultstyle;
        } break;
    }
    
    if (left && bottom) {
        return HWXYGraphAnnotationStyleBottomLeft;
    } else if (!left && bottom) {
        return HWXYGraphAnnotationStyleBottomRight;
    } else if (left && !bottom) {
        return HWXYGraphAnnotationStyleTopLeft;
    } else if (!left && !bottom) {
        return HWXYGraphAnnotationStyleTopRight;
    }
    
    return defaultstyle;
}

- (void)clipsAnnotation:(CPTPlotSpaceAnnotation *)anno path:(UIBezierPath *)path {
    if (anno) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = path.CGPath;
        anno.contentLayer.mask = maskLayer;
    }
}

// 设置标注文字
- (void)configureAnnotation:(CPTPlotSpaceAnnotation *)anno text:(NSAttributedString *)text bgColor:(UIColor *)bgColor {
    
    if (!anno || !anno.contentLayer) return;
    
    anno.contentLayer.backgroundColor = bgColor.CGColor;
    
    if (![anno.contentLayer isKindOfClass:[CPTTextLayer class]]) return;
    
    CPTTextLayer *annoTextLayer = (CPTTextLayer *)anno.contentLayer;
    
    if (text) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        __block BOOL didSetFont = NO;
        [text enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, text.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if (range.location != NSNotFound && value) {
                didSetFont = YES;
                *stop = YES;
            }
        }];
        didSetFont ? : [str addAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:10.0f] }
                                    range:NSMakeRange(0, text.length)];
        annoTextLayer.attributedText = str;
    } else {
        annoTextLayer.attributedText = text;
    }
}

- (void)addAnnotation:(CPTPlotSpaceAnnotation *)anno forLine:(HWXYGraphLine *)line {
    if (anno) {
        
        // remove
        [self removeAnnotation:anno forLine:line];
        
        // add
        [self addAnnotation:anno];
        if (line) {
            [line.annos addObject:anno];
        }
    }
}

- (void)removeAnnotation:(CPTPlotSpaceAnnotation *)anno forLine:(HWXYGraphLine *)line {
    if (anno) {
        [self removeAnnotation:anno];
        if (line) {
            [line.annos removeObject:anno];
        }
    }
}

- (void)removeAllAnnotationsForLine:(HWXYGraphLine *)line {
    for (CPTPlotSpaceAnnotation *anno in line.annos) {
        [self removeAnnotation:anno forLine:line];
    }
}

- (void)removeAllAnnotations {
    [self.plotAreaLayer.plotArea removeAllAnnotations];
    for (HWXYGraphLine *line in self.lines) {
        [line.annos removeAllObjects];
    }
}

#pragma mark -

- (void)addAnnotation:(CPTPlotSpaceAnnotation *)anno {
    if (anno) {
        [self.plotAreaLayer.plotArea addAnnotation:anno];
    }
}

- (void)removeAnnotation:(CPTPlotSpaceAnnotation *)anno {
    if (anno && anno.contentLayer.superlayer) {
        [self.plotAreaLayer.plotArea removeAnnotation:anno];
    }
}

- (CPTPlotSpaceAnnotation *)annotation {
    CPTPlotSpaceAnnotation *annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.hostedGraph.defaultPlotSpace anchorPlotPoint:nil];
    annotation.displacement = CGPointMake(0.0, 0.0);
    annotation.contentLayer = [self annotationTextLayer];
    return annotation;
}

// 懒加载标注风格
- (CPTTextLayer *)annotationTextLayer {
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor whiteColor];
    textStyle.fontSize = 10.0f;
    textStyle.textAlignment = CPTTextAlignmentCenter;
    textStyle.fontName = kFONT(kFontSize_h9).fontName;
    
    CPTTextLayer *annoTextLayer = [[CPTTextLayer alloc] initWithText:@"" style:textStyle];
    [self setPaddings:UIEdgeInsetsZero forLayer:annoTextLayer];
    
    return annoTextLayer;
}

#pragma mark - lazy

- (UILabel *)nullPointsInfoLabel {
    if (!_nullPointsInfoLabel) {
        _nullPointsInfoLabel =  [UILabel labelWithText:nil font:[UIFont systemFontOfSize:15] textColor:kNullPointsInfoLabelTextColor alignment:NSTextAlignmentCenter];
        _nullPointsInfoLabel.layer.transform = CATransform3DMakeScale((CGFloat)1.0, (CGFloat)-1.0, (CGFloat)1.0);
    }
    return _nullPointsInfoLabel;
}

// 懒加载标注
- (CPTPlotSpaceAnnotation *)interactionAnnotation {
    if (_interactionAnnotation == nil) {
        _interactionAnnotation = [self annotation];
    }
    return _interactionAnnotation;
}

#pragma mark - other

- (CPTAlignment)cptAlignmentForNSAlignment:(NSTextAlignment)alignment {
    NSDictionary <NSNumber *, NSNumber *>*map = @{@(NSTextAlignmentLeft) : @(CPTAlignmentRight),
                                                  @(NSTextAlignmentRight) : @(CPTAlignmentLeft),
                                                  @(NSTextAlignmentCenter) : @(CPTAlignmentCenter),
                                                  @(NSTextAlignmentJustified) : @(CPTAlignmentCenter),
                                                  @(NSTextAlignmentNatural) : @(CPTAlignmentCenter)};
    NSNumber *value = map[@(alignment)];
    return value ? value.integerValue : CPTAlignmentCenter;
}

// 小数位四舍五入取整
- (NSInteger)roundValueWithNumber:(NSNumber *)num {
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                      scale:0
                                                                                           raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    
    NSDecimalNumber *ouncesDecimal = [[NSDecimalNumber alloc] initWithString:num.stringValue];
    NSDecimalNumber *roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return roundedOunces.integerValue;
}

- (void)dealloc {
}

@end

#pragma mark - extension

@implementation UIBezierPath (HWXYGraph)

+ (UIBezierPath *)annotationPathWithSize:(CGSize)size cornerRadius:(CGFloat)radius {
    return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:radius];
}

+ (UIBezierPath *)leftTopAnnotationPathWithSize:(CGSize)size cornerRadius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, radius)];
    
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:M_PI * 1.5f clockwise:YES];
    [path addLineToPoint:CGPointMake(size.width - radius, 0)];
    
    [path addArcWithCenter:CGPointMake(size.width - radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(size.width, size.height - 4)];
    
    [path addArcWithCenter:CGPointMake(size.width - radius, size.height - 4 - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(4, size.height - 4)];
    [path addLineToPoint:CGPointMake(0, size.height)];
    [path closePath];
    
    return path;
}

+ (UIBezierPath *)leftBottomAnnotationPathWithSize:(CGSize)size cornerRadius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(4, 4)];
    [path addLineToPoint:CGPointMake(size.width - radius, 4)];
    
    [path addArcWithCenter:CGPointMake(size.width - radius, radius + 4) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(size.width, size.height - radius)];
    
    [path addArcWithCenter:CGPointMake(size.width - radius, size.height - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(radius, size.height)];
    
    [path addArcWithCenter:CGPointMake(radius, size.height - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    [path closePath];
    
    return path;
}

+ (UIBezierPath *)rightTopAnnotationPathWithSize:(CGSize)size cornerRadius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, radius)];
    
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:M_PI * 1.5f clockwise:YES];
    [path addLineToPoint:CGPointMake(size.width - radius, 0)];
    
    [path addArcWithCenter:CGPointMake(size.width - radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(size.width, size.height)];
    [path addLineToPoint:CGPointMake(size.width - 4, size.height - 4)];
    [path addLineToPoint:CGPointMake(radius, size.height - 4)];
    
    [path addArcWithCenter:CGPointMake(radius, size.height - 4 - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    [path closePath];
    
    return path;
}

+ (UIBezierPath *)rightBottomAnnotationPathWithSize:(CGSize)size cornerRadius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, radius + 4)];
    
    [path addArcWithCenter:CGPointMake(radius, radius + 4) radius:radius startAngle:M_PI endAngle:M_PI * 1.5f clockwise:YES];
    [path addLineToPoint:CGPointMake(size.width - 4, 4)];
    [path addLineToPoint:CGPointMake(size.width, 0)];
    [path addLineToPoint:CGPointMake(size.width, size.height - radius)];
    
    [path addArcWithCenter:CGPointMake(size.width - radius, size.height - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(radius, size.height)];
    
    [path addArcWithCenter:CGPointMake(radius, size.height - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    [path closePath];
    
    return path;
}

@end

// 渐变色
@implementation CPTGradient (HWXYGraph)

+ (CPTGradient *)redGradient {
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithCGColor:[[UIColor orangeColor] colorWithAlphaComponent:0.2].CGColor] endingColor:[CPTColor colorWithCGColor:[[UIColor orangeColor] colorWithAlphaComponent:0.0].CGColor]];
    gradient.angle = -90.0;
    return gradient;
}

@end

// 曲线属性
@implementation CPTMutableLineStyle (HWXYGraph)

+ (CPTMutableLineStyle *)lineStyleWithColor:(UIColor *)color lineWidth:(CGFloat)lineWidth {
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit = 0.0;
    lineStyle.lineCap = kCGLineCapRound;
    lineStyle.lineJoin = kCGLineJoinRound;
    lineStyle.lineWidth = lineWidth;
    lineStyle.lineColor = [CPTColor colorWithCGColor:color.CGColor];
    return lineStyle;
}

+ (CPTMutableLineStyle *)redLineStyle {
    return [self lineStyleWithColor:[UIColor colorWithHex:0xff5738] lineWidth:1.0f];
}

+ (CPTMutableLineStyle *)blueLineStyle {
    return [self lineStyleWithColor:[UIColor colorWithHex:0x8ebaff] lineWidth:1.0f];
}

+ (CPTMutableLineStyle *)yellowLineStyle {
    return [self lineStyleWithColor:[UIColor colorWithHex:0xffc158] lineWidth:1.0f];
}

@end

BOOL isInvalidNumberString(NSString *str) {
    if (str == nil || str.length == 0 || [[NSDecimalNumber decimalNumberWithString:str] isEqual:[NSDecimalNumber notANumber]]) {
        return YES;
    }
    
    BOOL flg = YES;
    for (NSInteger i=0; i<str.length; i++) {
        if (![@".-" rangeOfString:[str substringWithRange:NSMakeRange(i, 1)]].length) {
            flg = NO;
            break;
        }
    }
    return flg;
}
