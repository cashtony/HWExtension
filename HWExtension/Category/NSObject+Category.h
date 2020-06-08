//
//  NSObject+Category.h
//  HWExtension
//
//  Created by houwen.wang on 2016/11/8.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Rumtime.h"

NS_ASSUME_NONNULL_BEGIN

// perform block
#define performBlock(b, ...) \
    if (b) {                 \
        b(__VA_ARGS__);      \
    }

// perform block
#define performReturnValueBlock(b, nilReturnValue, ...) \
    if (b) {                                            \
        return b(__VA_ARGS__);                          \
    } else {                                            \
        return nilReturnValue;                          \
    }

@protocol HWKeyValuesProtocol <NSObject>

// key:属性名, value:属性值
@property (nonatomic, assign, readonly) NSDictionary<NSString *, id> *propertyKeyValues;

/**
 * 生成字典时, 需要重新修改属性名的属性
 *
 @return key:原始属性名 value:新属性名
 */
+ (NSDictionary<NSString *, NSString *> *)replacedKeyForPropertyKeyValues;

/**
 * 生成字典时, 需要忽略的属性名
 *
 @return 忽略的属性名数组
 */
+ (NSArray<NSString *> *)ignoredPropertiesForPropertyKeyValues;

/**
 *  自定义转换
 *  @param oldValue 旧值
 *  @param property 属性名
 *  @return 新值
 */
+ (id)convertedValue:(id)oldValue property:(NSString *)property;

@end

typedef void (^KeyValueObserverChangedBlock)(NSString *keyPath,
                                             id object,
                                             NSDictionary<NSKeyValueChangeKey, id> *change,
                                             void *_Nullable context);

@interface NSObject (Category)

// 对象将被释放
@property (nonatomic, copy) void (^willDeallocBlock)(__unsafe_unretained id obj);

@end

@interface NSObject (NSKeyValueObserverRegistrationBlock)

// 监听属性变化
- (void)observeValueForKeyPath:(NSString *)keyPath
                       options:(NSKeyValueObservingOptions)options
                       context:(nullable NSString *)context
                   changeBlock:(nonnull KeyValueObserverChangedBlock)block;

// 监听一组属性变化
- (void)observeValueForKeyPaths:(NSArray<NSString *> *)keyPaths
                        options:(NSKeyValueObservingOptions)options
                        context:(nullable NSString *)context
                    changeBlock:(nonnull KeyValueObserverChangedBlock)block;

// block移除监听, 如果block == nil, 所有相同keyPath & 相同context的block将移除监听
- (void)removeObserveValueForBlock:(nullable KeyValueObserverChangedBlock)block
                           keyPath:(NSString *)keyPath
                           context:(nullable NSString *)context;

@end

@interface NSObject (KeyValues) <HWKeyValuesProtocol>
@end

NS_ASSUME_NONNULL_END
