//
//  CPTXYAxis+Category.m
//  HXXjb
//
//  Created by houwen.wang on 16/8/19.
//  Copyright © 2016年 com.shhxzq. All rights reserved.
//

#import "CPTXYAxis+Category.h"

@implementation CPTXYAxis (Category)

// 替换原有类的实现
- (void)drawGridLinesInContext:(nonnull CGContextRef)context isMajor:(BOOL)major {
    CPTLineStyle *lineStyle = (major ? self.majorGridLineStyle : self.minorGridLineStyle);
    
    if (lineStyle) {
        [super renderAsVectorInContext:context];
        
        [self relabel];
        
        CPTPlotSpace *thePlotSpace = self.plotSpace;
        CPTNumberSet *locations = (major ? self.majorTickLocations : self.minorTickLocations);
        CPTCoordinate selfCoordinate = self.coordinate;
        CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(selfCoordinate);
        CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
        CPTPlotRange *theGridLineRange = self.gridLinesRange;
        CPTMutablePlotRange *labeledRange = nil;
        
        switch (self.labelingPolicy) {
            case CPTAxisLabelingPolicyNone:
            case CPTAxisLabelingPolicyLocationsProvided: {
                labeledRange = [[self.plotSpace plotRangeForCoordinate:self.coordinate] mutableCopy];
                CPTPlotRange *theVisibleRange = self.visibleRange;
                if (theVisibleRange) {
                    [labeledRange intersectionPlotRange:theVisibleRange];
                }
            } break;
                
            default:
                break;
        }
        
        if (theGridLineRange) {
            [orthogonalRange intersectionPlotRange:theGridLineRange];
        }
        
        CPTPlotArea *thePlotArea = self.plotArea;
        NSDecimal startPlotPoint[2];
        NSDecimal endPlotPoint[2];
        startPlotPoint[orthogonalCoordinate] = orthogonalRange.locationDecimal;
        endPlotPoint[orthogonalCoordinate] = orthogonalRange.endDecimal;
        CGPoint originTransformed = [self convertPoint:self.bounds.origin fromLayer:thePlotArea];
        
        CGFloat lineWidth = lineStyle.lineWidth;
        
        CPTAlignPointFunction alignmentFunction = NULL;
        if ((self.contentsScale > CPTFloat(1.0)) && (round(lineWidth) == lineWidth)) {
            alignmentFunction = CPTAlignIntegralPointToUserSpace;
        } else {
            alignmentFunction = CPTAlignPointToUserSpace;
        }
        
        CGContextBeginPath(context);
        
        for (NSDecimalNumber *location in locations) {
            NSDecimal locationDecimal = location.decimalValue;
            
            /******************************************************************************
             *                                   修改部分                                   *
             ******************************************************************************/
            CPTNumberArray *arr = locations.allObjects;
            if (arr && arr.count) {
                arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                    NSNumber *n1 = obj1;
                    NSNumber *n2 = obj2;
                    return [n1 compare:n2];
                }];
                
                // 不需要绘制的网格线
                if ([self.ignoreMajorGridLineIndexs containsObject:@([arr indexOfObject:location])]) {
                    continue;
                }
            }
            /******************************************************************************
             *                                   修改结束                                   *
             ******************************************************************************/
            
            if (labeledRange && ![labeledRange contains:locationDecimal]) {
                continue;
            }
            
            startPlotPoint[selfCoordinate] = locationDecimal;
            endPlotPoint[selfCoordinate] = locationDecimal;
            
            // Start point
            CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2];
            startViewPoint.x += originTransformed.x;
            startViewPoint.y += originTransformed.y;
            
            // End point
            CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2];
            endViewPoint.x += originTransformed.x;
            endViewPoint.y += originTransformed.y;
            
            // Align to pixels
            startViewPoint = alignmentFunction(context, startViewPoint);
            endViewPoint = alignmentFunction(context, endViewPoint);
            
            // Add grid line
            CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
            CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
        }
        
        // Stroke grid lines
        [lineStyle setLineStyleInContext:context];
        [lineStyle strokePathInContext:context];
    }
}

- (NSArray<NSNumber *> *)ignoreMajorGridLineIndexs {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setIgnoreMajorGridLineIndexs:(NSArray<NSNumber *> *)ignoreMajorGridLineIndexs {
    objc_setAssociatedObject(self, @selector(ignoreMajorGridLineIndexs), ignoreMajorGridLineIndexs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
