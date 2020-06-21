//
//  NSIndexPath+HWAdditions.h
//  HWExtension
//
//  Created by Wang,Houwen on 2020/4/7.
//  Copyright © 2020 Wang,Houwen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSIndexPath (HWAdditions)

+ (instancetype)indexPathForPage:(NSInteger)page inGroup:(NSInteger)group;

@property (nonatomic, readonly) NSInteger group;
@property (nonatomic, readonly) NSInteger page;

@end

NS_ASSUME_NONNULL_END
