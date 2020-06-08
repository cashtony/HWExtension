//
//  NSObject+Category.m
//  HWExtension
//
//  Created by houwen.wang on 2016/11/8.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "NSObject+Category.h"

static NSMutableSet *swizzledClasses() {
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    return swizzledClasses;
}

static void swizzleDeallocIfNeeded(Class classToSwizzle) {
    @synchronized(swizzledClasses()) {
        NSString *className = NSStringFromClass(classToSwizzle);
        if ([swizzledClasses() containsObject:className])
            return;

        SEL deallocSelector = sel_registerName("dealloc");
        __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;

        id newDealloc = ^(__unsafe_unretained NSObject *self) {
            if (self.willDeallocBlock) {
                self.willDeallocBlock(self);
            }
            if (originalDealloc == NULL) {
                struct objc_super superInfo =
                    {
                        .receiver = self,
                        .super_class = class_getSuperclass(classToSwizzle)};
                void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                msgSend(&superInfo, deallocSelector);
            } else {
                originalDealloc(self, deallocSelector);
            }
        };

        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        if (!class_addMethod(classToSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            Method deallocMethod = class_getInstanceMethod(classToSwizzle, deallocSelector);
            originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
            originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, newDeallocIMP);
        }
        [swizzledClasses() addObject:className];
    }
}

@implementation NSObject (Category)

- (void (^)(__unsafe_unretained id))willDeallocBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWillDeallocBlock:(void (^)(__unsafe_unretained id))willDeallocBlock {
    if (self.willDeallocBlock != willDeallocBlock) {
        swizzleDeallocIfNeeded(self.class);
        objc_setAssociatedObject(self,
                                 @selector(willDeallocBlock),
                                 willDeallocBlock,
                                 OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"\n \"%@\" class hasn't \"%@\" key!!!\n", self.class, key);
    return [NSNull null];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"\n \"%@\" class hasn't \"%@\" key!!!\n", self.class, key);
}

- (void)setNilValueForKey:(NSString *)key {
}

@end

@class HWKeyValueObserver;

typedef void (^KeyValueChangedHandlerBlock)(HWKeyValueObserver *observer,
                                            NSString *keyPath,
                                            id object,
                                            NSDictionary<NSKeyValueChangeKey, id> *change,
                                            void *context);

@interface HWKeyValueObserver : NSObject

@property (nonatomic, weak) id obj;
@property (nonatomic, strong) NSMutableSet<NSString *> *observerPaths;
@property (nonatomic, copy) KeyValueChangedHandlerBlock changedHandlerBlock;

@end

@implementation HWKeyValueObserver

+ (instancetype)observerWithHandler:(KeyValueChangedHandlerBlock)handler {
    HWKeyValueObserver *observer = [[[HWKeyValueObserver class] alloc] init];
    observer.changedHandlerBlock = handler;
    return observer;
}

- (void)observeValueForObject:(id)obj
                   forKeyPath:(NSString *)keyPath
                      options:(NSKeyValueObservingOptions)options
                      context:(nullable NSString *)context {
    if (obj && keyPath && keyPath.length) {
        NSString *path = [NSString stringWithFormat:@"%@:%@", keyPath, context];
        if (![self.observerPaths containsObject:path]) {
            self.obj = obj;
            [self.observerPaths addObject:[NSString stringWithFormat:@"%@:%@", keyPath, context]];
            [obj addObserver:self forKeyPath:keyPath options:options context:(__bridge void *)(context)];
        }
    }
}

- (void)removeObserveValueForKeyPath:(NSString *)keyPath
                             context:(nullable NSString *)context {
    NSString *path = [NSString stringWithFormat:@"%@:%@", keyPath, context];
    if ([self.observerPaths containsObject:path]) {
        [self.observerPaths removeObject:path];
        [self.obj removeObserver:self forKeyPath:keyPath context:(__bridge void *_Nullable)(context)];
    }
}

- (NSMutableSet<NSString *> *)observerPaths {
    if (_observerPaths == nil) {
        _observerPaths = [NSMutableSet set];
    }
    return _observerPaths;
}

#pragma mark - KVO callback

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    !self.changedHandlerBlock ?: self.changedHandlerBlock(self, keyPath, object, change, context);
}

- (void)dealloc {
    for (NSString *path in self.observerPaths) {
        NSArray<NSString *> *path_t = [path componentsSeparatedByString:@":"];
        [self.obj removeObserver:self forKeyPath:path_t[0] context:(__bridge void *)(path_t[1])];
    }
}

@end

const void *_Nonnull HWKeyValueObserversKey = &HWKeyValueObserversKey;

@implementation NSObject (NSKeyValueObserverRegistrationBlock)

- (void)observeValueForKeyPath:(NSString *)keyPath
                       options:(NSKeyValueObservingOptions)options
                       context:(nullable NSString *)context
                   changeBlock:(nonnull KeyValueObserverChangedBlock)block {
    @synchronized(self) {
        if (keyPath && keyPath.length && block) {
            NSMutableDictionary<KeyValueObserverChangedBlock, HWKeyValueObserver *> *observers = objc_getAssociatedObject(self, HWKeyValueObserversKey);

            if (observers == nil) {
                observers = [NSMutableDictionary dictionary];
                objc_setAssociatedObject(self, HWKeyValueObserversKey, observers, OBJC_ASSOCIATION_RETAIN);
            }

            HWKeyValueObserver *observer = observers[(id)block];
            if (observer == nil) {
                observer = [HWKeyValueObserver observerWithHandler:^(HWKeyValueObserver *observer_t,
                                                                     NSString *keyPath,
                                                                     id object,
                                                                     NSDictionary<NSKeyValueChangeKey, id> *change,
                                                                     void *context) {
                    NSDictionary<KeyValueObserverChangedBlock, HWKeyValueObserver *> *observers_t = objc_getAssociatedObject(object, HWKeyValueObserversKey);

                    [observers_t enumerateKeysAndObjectsUsingBlock:^(KeyValueObserverChangedBlock key,
                                                                     HWKeyValueObserver *obj,
                                                                     BOOL *stop) {
                        if ([obj isEqual:observer_t]) {
                            key(keyPath, object, change, context);
                            *stop = YES;
                        }
                    }];
                }];
                observers[(id)block] = observer;
            }
            [observer observeValueForObject:self forKeyPath:keyPath options:options context:context];
        }
    }
}

- (void)observeValueForKeyPaths:(NSArray<NSString *> *)keyPaths
                        options:(NSKeyValueObservingOptions)options
                        context:(nullable NSString *)context
                    changeBlock:(nonnull KeyValueObserverChangedBlock)block {
    if (block) {
        for (NSString *keyPath in keyPaths) {
            [self observeValueForKeyPath:keyPath options:options context:context changeBlock:block];
        }
    }
}

// block移除监听, 如果block == nil, 所有相同keyPath & 相同context的block将移除监听
- (void)removeObserveValueForBlock:(nullable KeyValueObserverChangedBlock)block
                           keyPath:(NSString *)keyPath
                           context:(nullable NSString *)context {
    @synchronized(self) {
        NSMutableDictionary<KeyValueObserverChangedBlock, HWKeyValueObserver *> *observers = objc_getAssociatedObject(self, HWKeyValueObserversKey);

        if (observers && observers.count) {
            if (block) {
                HWKeyValueObserver *observer = observers[(id)block];
                if (observer) {
                    [observer removeObserveValueForKeyPath:keyPath context:context];
                }
            } else {
                [observers enumerateKeysAndObjectsUsingBlock:^(KeyValueObserverChangedBlock key,
                                                               HWKeyValueObserver *obj,
                                                               BOOL *stop) {
                    [obj removeObserveValueForKeyPath:keyPath context:context];
                }];
            }

            // remove none keyPath & context observer
            __block NSMutableArray<KeyValueObserverChangedBlock> *shouldRemovedObservers = [NSMutableArray array];
            [observers enumerateKeysAndObjectsUsingBlock:^(KeyValueObserverChangedBlock key,
                                                           HWKeyValueObserver *obj,
                                                           BOOL *stop) {
                if (obj.observerPaths.count == 0) {
                    [shouldRemovedObservers addObject:key];
                }
            }];
            [observers removeObjectsForKeys:shouldRemovedObservers];
        }
    }
}

@end

@implementation NSObject (KeyValues)

- (NSDictionary<NSString *, id> *)propertyKeyValues {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    __weak typeof(self) ws = self;
    [propertyListEndOfClass(self.class, [NSObject class]) enumerateObjectsUsingBlock:^(HWPropertyInfo *obj,
                                                                                       NSUInteger idx,
                                                                                       BOOL *stop) {
        __strong typeof(ws) ss = ws;
        // 未被忽略
        if (![[ss.class ignoredPropertiesForPropertyKeyValues] containsObject:obj.name]) {
            id value = [ss valueForKey:obj.name];
            value = [ss.class convertedValue:value property:obj.name];

            NSString *replacedKey = [ss.class replacedKeyForPropertyKeyValues][obj.name];
            NSString *key = replacedKey ? replacedKey : obj.name;

            if (value) {
                dic[key] = value;
            } else {
                if ([obj.cls isSubclassOfClass:[NSString class]]) {
                    dic[key] = @"";
                } else if ([obj.cls isSubclassOfClass:[NSArray class]]) {
                    dic[key] = @[];
                } else if ([obj.cls isSubclassOfClass:[NSDictionary class]]) {
                    dic[key] = @{};
                }
            }
        };
    }];
    return [dic copy];
}

//  生成字典时，需要重新修改属性名的属性
+ (NSDictionary<NSString *, NSString *> *)replacedKeyForPropertyKeyValues {
    return nil;
}

/**
 * 生成字典时, 需要忽略的属性名
 *
 @return 忽略的属性名数组
 */
+ (NSArray<NSString *> *)ignoredPropertiesForPropertyKeyValues {
    return nil;
}

/**
 *  自定义转换
 *  @param oldValue 旧值
 *  @param property 属性名
 *  @return 新值
 */
+ (id)convertedValue:(id)oldValue property:(NSString *)property {
    return oldValue;
}

@end
