//
//  HWXYGraphInteractionView.m
//  HWExtension
//
//  Created by houwen.wang on 16/8/12.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWXYGraphInteractionView.h"

@interface HWXYGraphInteractionView () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSArray <NSValue *>*crossPoints;                        // 十字交叉线的交点
@property (assign, nonatomic) BOOL clearContex;                                       // 是否需要清除已绘制的内容
@property (strong, nonatomic) UILongPressGestureRecognizer *longPrGestureRecognizer;  // 长按手势

@end

@implementation HWXYGraphInteractionView

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame recognizerWithHandler:(recognizerHandler)block {
    if (self = [super initWithFrame:frame]) {
        self.recognizerHandler = block;
        [self setup];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setup {
    self.multipleTouchEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.clearContex = YES;
}

- (void)setRecognizerHandler:(recognizerHandler)recognizerHandler {
    if (_recognizerHandler != recognizerHandler) {
        _recognizerHandler = nil;
        _recognizerHandler = recognizerHandler;
    }
    if (recognizerHandler) {
        if (!_longPrGestureRecognizer) {
            _longPrGestureRecognizer = [UILongPressGestureRecognizer gestureRecognizerWithHandler:^(__kindof UIGestureRecognizer *ges) {
                performBlock(recognizerHandler, ges, ges.state, [ges locationInView:ges.view]);
            }];
            _longPrGestureRecognizer.minimumPressDuration = 0.1;
            _longPrGestureRecognizer.allowableMovement = 3.0;
            [self addGestureRecognizer:_longPrGestureRecognizer];
        }
    } else {
        if (_longPrGestureRecognizer) {
            [_longPrGestureRecognizer removeGestureRecognizerHandler:nil];
            [self removeGestureRecognizer:_longPrGestureRecognizer];
            _longPrGestureRecognizer = nil;
        }
    }
}

- (void)showCrossLineWithPoints:(NSArray <NSValue *>*)points horizontal:(BOOL)horizontal vertical:(BOOL)vertical {
    
    self.clearContex = NO;
    
    self.crossPoints = points;
    self.showHorizontalLine = horizontal;
    self.showVerticalLine = vertical;
    
    [self setNeedsDisplay];
}

- (void)hiddenCrossLine {
    self.clearContex = YES;
    [self setNeedsDisplay];
}

#pragma mark - drawRect

- (void)drawRect:(CGRect)rect {
    // 获取绘图上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    if (self.clearContex) {
        return;
    }
    
    for (NSValue *pv in self.crossPoints) {
        
        CGPoint crossPoint = pv.CGPointValue;
        
        if (!CGRectContainsPoint(UIEdgeInsetsInsetRect(self.contentRect, UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f)) , crossPoint)) {
            continue;
        }
        
        // 初始化绘图上下文
        CGContextSetStrokeColorWithColor(ctx, self.lineColor ? self.lineColor.CGColor : [UIColor orangeColor].CGColor);  // 默认颜色
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(ctx, self.lineWidth <= 0.0f ? 1.0f : self.lineWidth);                                  // 默认宽度
        CGContextSetShouldAntialias(ctx, YES);
        
        // 垂直线
        if (self.showVerticalLine) {
            CGContextMoveToPoint(ctx, crossPoint.x, self.contentRect.origin.y);
            CGContextAddLineToPoint(ctx, crossPoint.x, CGRectGetMaxY(self.contentRect));
        }
        
        // 水平线
        if (self.showHorizontalLine) {
            CGContextMoveToPoint(ctx, self.contentRect.origin.x, crossPoint.y);
            CGContextAddLineToPoint(ctx, CGRectGetMaxX(self.contentRect), crossPoint.y);
        }
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        // 重新设置绘图上下文
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);               // 填充色
        CGContextSetLineWidth(ctx, self.crossLineWidth <= 0 ? 1 : self.crossLineWidth);  // 默认宽度
        CGContextSetStrokeColorWithColor(ctx, self.crossLineColor ? self.crossLineColor.CGColor : [UIColor orangeColor].CGColor);  // 默认颜色
        
        CGContextDrawPath(ctx, kCGPathFillStroke);
    }
    
    for (NSValue *pv in self.crossPoints) {
        CGPoint crossPoint = pv.CGPointValue;
        
        // 交叉点
        if (MIN(self.crossSize.height, self.crossSize.width) > 0.0) {
            CGContextAddArc(ctx, crossPoint.x, crossPoint.y, MIN(self.crossSize.height, self.crossSize.width), 0,
                            2.0 * M_PI, YES);
        }
        CGContextDrawPath(ctx, kCGPathFillStroke);
    }
}

@end
