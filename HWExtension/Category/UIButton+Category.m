//
//  UIButton+Category.m
//  HWExtension
//
//  Created by houwen.wang on 16/6/6.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "UIButton+Category.h"

@interface UIButton ()

@property (assign, nonatomic) BOOL alreadySetTitleRect;     // 是否已设置过这个属性
@property (assign, nonatomic) BOOL alreadySetImageRect;     // 是否已设置过这个属性

@end

@implementation UIButton (Category)

+ (void) load {
    [self exchangeImplementations:@selector(titleRectForContentRect:) otherMethod:@selector(hw_titleRectForContentRect:) isInstance:YES];
    [self exchangeImplementations:@selector(imageRectForContentRect:) otherMethod:@selector(hw_imageRectForContentRect:) isInstance:YES];
}

- (CGRect) hw_titleRectForContentRect:(CGRect)contentRect {
    if (!self.alreadySetTitleRect) {
        return [self hw_titleRectForContentRect:contentRect];
    }
    return self.titleRect;
}

- (CGRect)hw_imageRectForContentRect:(CGRect)contentRect {
    if (!self.alreadySetImageRect) {
        return [self hw_imageRectForContentRect:contentRect];
    }
    return self.imageRect;
}

- (NSString *)linkURL {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLinkURL:(NSString *)linkURL {
    objc_setAssociatedObject(self, @selector(linkURL), linkURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)alreadySetTitleRect {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setAlreadySetTitleRect:(BOOL)alreadySetTitleRect {
    objc_setAssociatedObject(self, @selector(alreadySetTitleRect), @(alreadySetTitleRect), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)alreadySetImageRect {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setAlreadySetImageRect:(BOOL)alreadySetImageRect {
    objc_setAssociatedObject(self, @selector(alreadySetImageRect), @(alreadySetImageRect), OBJC_ASSOCIATION_ASSIGN);
}

- (CGRect) titleRect {
    return [objc_getAssociatedObject(self, _cmd) CGRectValue];
}

- (void) setTitleRect:(CGRect)titleRect {
    self.alreadySetTitleRect = YES;
    objc_setAssociatedObject(self, @selector(titleRect), [NSValue valueWithCGRect:titleRect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNeedsLayout];
    [self setNeedsUpdateConstraints]; // iOS 8 以前必须加上这句
}

- (CGRect) imageRect {
    return [objc_getAssociatedObject(self, _cmd) CGRectValue];
}

- (void) setImageRect:(CGRect)imageRect {
    self.alreadySetImageRect = YES;
    objc_setAssociatedObject(self, @selector(imageRect), [NSValue valueWithCGRect:imageRect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNeedsLayout];
    [self setNeedsUpdateConstraints]; // iOS 8 以前必须加上这句
}

@end

