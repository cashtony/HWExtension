//
//  NSIndexPath+HWAdditions.m
//  HWExtension
//
//  Created by Wang,Houwen on 2020/4/7.
//  Copyright © 2020 Wang,Houwen. All rights reserved.
//

#import "NSIndexPath+HWAdditions.h"

@implementation NSIndexPath (HWAdditions)

+ (instancetype)indexPathForPage:(NSInteger)page inGroup:(NSInteger)group {
    return [self indexPathForRow:page inSection:group];
}

- (NSInteger)page {
    return self.row;
}

- (NSInteger)group {
    return self.section;
}

@end
