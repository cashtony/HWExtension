//
//  HWGroupViewControllerContent.h
//  HWExtension
//
//  Created by Wang,Houwen on 2020/4/13.
//  Copyright © 2020 shimingwei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HWGroupViewControllerContent <NSObject>

@required
@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

@optional
@property (nonatomic, strong, readonly, nullable) UIScrollView *scrollView;

- (void)prepareForReuse;
- (void)didEndDisplaying;

@end

NS_ASSUME_NONNULL_END
