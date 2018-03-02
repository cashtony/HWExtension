//
//  HWGraphicViewController.m
//  HWExtension_Example
//
//  Created by wanghouwen on 2018/3/2.
//  Copyright © 2018年 wanghouwen. All rights reserved.
//

#import "HWGraphicViewController.h"

@interface HWGraphicViewController () <HWXYGraphHostingViewDelegate>

@property (nonatomic, strong) HWXYGraphHostingView *xyGraphHostingView;    //

@end

@implementation HWGraphicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    [self addLines];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.xyGraphHostingView.frame = self.view.bounds;
}

- (void)initUI {
    if (self.xyGraphHostingView.superview == nil) {
        [self.view addSubview:self.xyGraphHostingView];
        
        __weak typeof(self) ws = self;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:@"刷新" actionHandler:^(UIBarButtonItem *item, UIButton *customView) {
            __strong typeof(ws) ss = ws;
            [ss addLines];
        }];
    }
}

#pragma mark -

- (void)addLines {
    
    HWXYGraphLine *redLine = [HWXYGraphLine lineWithId:@"red" lineStyle:[CPTMutableLineStyle redLineStyle] points:nil];
    HWXYGraphLine *blueLine = [HWXYGraphLine lineWithId:@"blue" lineStyle:[CPTMutableLineStyle blueLineStyle] points:nil];
    HWXYGraphLine *yellowLine = [HWXYGraphLine lineWithId:@"yellow" lineStyle:[CPTMutableLineStyle yellowLineStyle] points:nil];
    
    NSMutableArray *redLinePoints = [NSMutableArray array];
    NSMutableArray *blueLinePoints = [NSMutableArray array];
    NSMutableArray *yellowLinePoints = [NSMutableArray array];
    
    for (int i=0; i<100; i++) {
        
        NSString *x = @(i).stringValue;
        NSString *y = @((arc4random() % 30 + 60) / 100.0f).stringValue;
        
        HWXYGraphValue *redValue = [HWXYGraphValue xyValueWithStringX:x stringY:y];
        HWXYGraphPoint *redPoint = [HWXYGraphPoint pointWithXYValue:redValue plotSymbol:nil xTickLabel:[NSString stringWithFormat:@"第%@个数据", x]];
        
        y = @((arc4random() % 30 + 30) / 100.0f).stringValue;
        
        HWXYGraphValue *blueValue = [HWXYGraphValue xyValueWithStringX:x stringY:y];
        HWXYGraphPoint *bluePoint = [HWXYGraphPoint pointWithXYValue:blueValue plotSymbol:nil xTickLabel:[NSString stringWithFormat:@"第%@个数据", x]];
        bluePoint.userInfo = @{x : y};
        
        y = @((arc4random() % 30) / 100.0f).stringValue;
        
        HWXYGraphValue *yellowValue = [HWXYGraphValue xyValueWithStringX:x stringY:y];
        HWXYGraphPoint *yellowPoint = [HWXYGraphPoint pointWithXYValue:yellowValue plotSymbol:nil xTickLabel:[NSString stringWithFormat:@"第%@个数据", x]];
        
        [redLinePoints addObject:redPoint];
        [blueLinePoints addObject:bluePoint];
        [yellowLinePoints addObject:yellowPoint];
    }
    
    redLine.points = redLinePoints;
    blueLine.points = blueLinePoints;
    yellowLine.points = yellowLinePoints;
    
    [self.xyGraphHostingView removeAllLine];
    [self.xyGraphHostingView addLines:@[redLine, blueLine, yellowLine]];
    self.xyGraphHostingView.interactionDateSourceIds = @[@"blue"];
    [self.xyGraphHostingView reloadDataWithResetAxisSet:YES];
}

#pragma mark - lazy load

- (HWXYGraphHostingView *)xyGraphHostingView {
    if (_xyGraphHostingView == nil) {
        _xyGraphHostingView = [[HWXYGraphHostingView alloc] init];
        _xyGraphHostingView.plotAreaLayerEdgeInsets = UIEdgeInsetsMake(50, 60, 50, 50);
        _xyGraphHostingView.xIgnoreMajorGridLineIndexs = @[@0, @2];
        _xyGraphHostingView.yIgnoreMajorGridLineIndexs = @[@0];
        
        NSNumberFormatter *yFormatter = [[NSNumberFormatter alloc] init];
        yFormatter.positiveFormat = @"##0.00%";
        _xyGraphHostingView.yLabelFormatter = yFormatter;
        
        _xyGraphHostingView.delegate = self;
    }
    return _xyGraphHostingView;
}

#pragma mark - HWXYGraphHostingViewDelegate

- (nullable NSAttributedString *)annotationTextForXYGraphHostingView:(HWXYGraphHostingView *)xyGraphHostingView
                                                              points:(NSArray <HWXYGraphPoint *>*)points
                                                    interactionState:(HWInteractionState)interactionState {
    // 交互中
    if (interactionState == HWInteractioningState) {
        
        NSDictionary *dic = points[0].userInfo;
        return [[NSString stringWithFormat:@"第%@个数据：\n值：%@", dic.allKeys.firstObject, dic.allValues.firstObject] attributedStringWithColor:[UIColor whiteColor]];
        
    }// 结束
    else {
        
    }
    return nil;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
