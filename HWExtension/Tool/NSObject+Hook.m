//
//  NSObject+Hook.m
//  HWRuntime_Example
//
//  Created by Wang,Houwen on 2019/8/17.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "NSObject+Hook.h"

static NSMutableSet *_classHookMethods_ = nil;
static NSMutableSet *_instanceHookMethods_ = nil;
static NSMutableDictionary *_classMethodHookBeforeHandlers_ = nil;
static NSMutableDictionary *_instanceMethodHookBeforeHandlers_ = nil;
static NSMutableDictionary *_classMethodHookAfterHandlers_ = nil;
static NSMutableDictionary *_instanceMethodHookAfterHandlers_ = nil;

typedef void (^HWMethodHookHandlerBlock)(id _Nonnull target,
                                         SEL sel,
                                         BOOL instance,
                                         HWMethodHookTime time,
                                         va_list _Nullable args);

#define argNone
#define ownershipNone
#define returnType(_type) _type
#define initReturnValue(_value) _value
#define ownershipAutoreleasing __autoreleasing

#define arg(_argType, _index)                             \
    {                                                     \
        if (signature.numberOfArguments > _index) {       \
            _argType arg = va_arg(args, _argType);        \
            [invocation setArgument:&arg atIndex:_index]; \
        }                                                 \
    }

#define HWHookVoidReturnClassMethod(_obj, _sel, _time, _handler, _args) \
    HWHookMethod(_obj, _sel, _time, NO, _handler, id, nil, ownershipNone, _args)

#define HWHookVoidReturnInstanceMethod(_obj, _sel, _time, _handler, _args) \
    HWHookMethod(_obj, _sel, _time, YES, _handler, id, nil, ownershipNone, _args)

#define HWHookMethod(_obj, _sel, _time, _instance, _handler, _returnType, _initReturnValue, _ownership, _args)                                                               \
    {                                                                                                                                                                        \
        if (!_classHookMethods_) {                                                                                                                                           \
            _classHookMethods_ = [NSMutableSet set];                                                                                                                         \
        }                                                                                                                                                                    \
        if (!_instanceHookMethods_) {                                                                                                                                        \
            _instanceHookMethods_ = [NSMutableSet set];                                                                                                                      \
        }                                                                                                                                                                    \
        if (!_classMethodHookBeforeHandlers_) {                                                                                                                              \
            _classMethodHookBeforeHandlers_ = [NSMutableDictionary dictionary];                                                                                              \
        }                                                                                                                                                                    \
        if (!_instanceMethodHookBeforeHandlers_) {                                                                                                                           \
            _instanceMethodHookBeforeHandlers_ = [NSMutableDictionary dictionary];                                                                                           \
        }                                                                                                                                                                    \
        if (!_classMethodHookAfterHandlers_) {                                                                                                                               \
            _classMethodHookAfterHandlers_ = [NSMutableDictionary dictionary];                                                                                               \
        }                                                                                                                                                                    \
        if (!_instanceMethodHookAfterHandlers_) {                                                                                                                            \
            _instanceMethodHookAfterHandlers_ = [NSMutableDictionary dictionary];                                                                                            \
        }                                                                                                                                                                    \
        id __obj = [_obj class];                                                                                                                                             \
        SEL __sel = _sel;                                                                                                                                                    \
        HWMethodHookTime __time = _time;                                                                                                                                     \
        BOOL __instance = _instance;                                                                                                                                         \
        HWMethodHookHandlerBlock __handler = _handler;                                                                                                                       \
        BOOL __hooked = NO;                                                                                                                                                  \
        if (__obj && __handler) {                                                                                                                                            \
            if (__instance && ![[__obj class] instancesRespondToSelector:__sel]) {                                                                                           \
                NSString *desc = [NSString stringWithFormat:@"找不到方法: -[%@ %@]", NSStringFromClass(__obj), NSStringFromSelector(__sel)];                            \
                NSAssert(0, desc);                                                                                                                                           \
            }                                                                                                                                                                \
            if (!__instance && ![[__obj class] respondsToSelector:__sel]) {                                                                                                  \
                NSString *desc = [NSString stringWithFormat:@"找不到方法: +[%@ %@]", NSStringFromClass(__obj), NSStringFromSelector(__sel)];                            \
                NSAssert(0, desc);                                                                                                                                           \
            }                                                                                                                                                                \
            NSMethodSignature *signature = __instance ? [[__obj class] instanceMethodSignatureForSelector:__sel] : [[__obj class] methodSignatureForSelector:__sel];         \
            BOOL after = (__time == HWMethodHookTimeAfter);                                                                                                                  \
            NSString *selName = NSStringFromSelector(__sel);                                                                                                                 \
            if (__instance) {                                                                                                                                                \
                NSMutableDictionary *handlers = (after ? _instanceMethodHookAfterHandlers_ : _instanceMethodHookBeforeHandlers_);                                            \
                if (!handlers[selName]) {                                                                                                                                    \
                    handlers[selName] = [NSMutableSet set];                                                                                                                  \
                }                                                                                                                                                            \
                [handlers[selName] addObject:__handler];                                                                                                                     \
                if ([_instanceHookMethods_ containsObject:selName]) {                                                                                                        \
                    __hooked = YES;                                                                                                                                          \
                }                                                                                                                                                            \
                __hooked ?: [_instanceHookMethods_ addObject:selName];                                                                                                       \
            } else {                                                                                                                                                         \
                NSMutableDictionary *handlers = (after ? _classMethodHookAfterHandlers_ : _classMethodHookBeforeHandlers_);                                                  \
                if (!handlers[selName]) {                                                                                                                                    \
                    handlers[selName] = [NSMutableSet set];                                                                                                                  \
                }                                                                                                                                                            \
                [handlers[selName] addObject:__handler];                                                                                                                     \
                if ([_classHookMethods_ containsObject:selName]) {                                                                                                           \
                    __hooked = YES;                                                                                                                                          \
                }                                                                                                                                                            \
                __hooked ?: [_classHookMethods_ addObject:selName];                                                                                                          \
            }                                                                                                                                                                \
            if (!__hooked) {                                                                                                                                                 \
                Method originalMethod = (__instance ? class_getInstanceMethod([__obj class], __sel) : class_getClassMethod([__obj class], __sel));                           \
                Method newMethod = NULL;                                                                                                                                     \
                IMP newIMP = NULL;                                                                                                                                           \
                SEL newSel = sel_registerName([NSString stringWithFormat:@"_hook%@_ORI_%@", (__instance ? @"Instance" : @"Class"), selName].UTF8String);                     \
                id newIMPBlock;                                                                                                                                              \
                setNewIMP(newSel, newIMPBlock, _returnType, _initReturnValue, _ownership, /*args*/ _args)                                                                    \
                    newIMP = imp_implementationWithBlock(newIMPBlock);                                                                                                       \
                class_addMethod(__instance ? [__obj class] : objc_getMetaClass(object_getClassName([__obj class])), newSel, newIMP, method_getTypeEncoding(originalMethod)); \
                newMethod = (__instance ? class_getInstanceMethod([__obj class], newSel) : class_getClassMethod([__obj class], newSel));                                     \
                method_exchangeImplementations(originalMethod, newMethod);                                                                                                   \
            }                                                                                                                                                                \
        }                                                                                                                                                                    \
    }

#define setNewIMP(_newMethodSEL, _newIMPBlock, _returnType, _initReturnValue, _ownership, _setArgs)                   \
    {                                                                                                                 \
        newIMPBlock = ^_returnType(__unsafe_unretained id target, ...) {                                              \
            NSString *newSelName = NSStringFromSelector(newSel);                                                      \
            NSString *oriSelName = [newSelName substringFromIndex:NSMaxRange([newSelName rangeOfString:@"ORI"]) + 1]; \
            BOOL instance = [newSelName hasPrefix:@"_hookInstance"];                                                  \
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];                        \
            invocation.target = target;                                                                               \
            invocation.selector = newSel;                                                                             \
            va_list args, argsCopy, argsCopy2;                                                                        \
            va_start(args, target);                                                                                   \
            __va_copy(argsCopy, args);                                                                                \
            __va_copy(argsCopy2, args);                                                                               \
            if (instance) {                                                                                           \
                for (HWMethodHookHandlerBlock handler in _instanceMethodHookBeforeHandlers_[oriSelName]) {            \
                    handler(target, NSSelectorFromString(oriSelName), instance, HWMethodHookTimeBefore, argsCopy);    \
                }                                                                                                     \
            } else {                                                                                                  \
                for (HWMethodHookHandlerBlock handler in _classMethodHookBeforeHandlers_[oriSelName]) {               \
                    handler(target, NSSelectorFromString(oriSelName), instance, HWMethodHookTimeBefore, argsCopy);    \
                }                                                                                                     \
            }                                                                                                         \
            _setArgs                                                                                                  \
                [invocation invoke];                                                                                  \
            if (instance) {                                                                                           \
                for (HWMethodHookHandlerBlock handler in _instanceMethodHookAfterHandlers_[oriSelName]) {             \
                    handler(target, NSSelectorFromString(oriSelName), instance, HWMethodHookTimeAfter, argsCopy2);    \
                }                                                                                                     \
            } else {                                                                                                  \
                for (HWMethodHookHandlerBlock handler in _classMethodHookAfterHandlers_[oriSelName]) {                \
                    handler(target, NSSelectorFromString(oriSelName), instance, HWMethodHookTimeAfter, argsCopy2);    \
                }                                                                                                     \
            }                                                                                                         \
            va_end(args);                                                                                             \
            va_end(argsCopy);                                                                                         \
            va_end(argsCopy2);                                                                                        \
            _ownership _returnType returnValue = _initReturnValue;                                                    \
            if (strcmp(signature.methodReturnType, @encode(void)) != 0) {                                             \
                [invocation getReturnValue:&returnValue];                                                             \
            }                                                                                                         \
            return returnValue;                                                                                       \
        };                                                                                                            \
    }

#define _HookIMP(_object, _sel, _instance, _time, _block, _args)                                                                              \
    {                                                                                                                                         \
        {                                                                                                                                     \
            HWMethodHookHandlerBlock block_t = ^(id _Nonnull target, SEL sel, BOOL instance, HWMethodHookTime time, va_list _Nullable args) { \
                !_block ?: _block(target, sel, args);                                                                                         \
            };                                                                                                                                \
            HWHookMethod(_object, _sel, _time, _instance, block_t, returnType(id), initReturnValue(NULL), ownershipNone, _args)               \
        }                                                                                                                                     \
    }

#define HookIMP(_object, _sel, _instance, _before, _after, _args)                    \
    {                                                                                \
        _HookIMP(_object, _sel, _instance, HWMethodHookTimeBefore, _before, _args)   \
            _HookIMP(_object, _sel, _instance, HWMethodHookTimeAfter, _after, _args) \
    }

@implementation NSObject (Hook)

+ (void)hookMethod:(SEL)sel
          instance:(BOOL)instance
            before:(void (^)(id target, SEL sel, va_list args))before
             after:(void (^)(id target, SEL sel, va_list args))after {
    NSString *selName = NSStringFromSelector(sel);
    NSInteger pc = [selName componentsSeparatedByString:@":"].count - 1;
    switch (pc) {
        case 0:
            HookIMP(self, sel, instance, before, after, argNone) break;

        case 1:
            HookIMP(self, sel, instance, before, after, arg(id, 2);) break;

        case 2:
            HookIMP(self, sel, instance, before, after, arg(id, 2); arg(id, 3);) break;

        case 3:
            HookIMP(self, sel, instance, before, after, arg(id, 2); arg(id, 3); arg(id, 4)) break;

        case 4:
            HookIMP(self, sel, instance, before, after, arg(id, 2); arg(id, 3); arg(id, 4); arg(id, 5)) break;

        case 5:
            HookIMP(self, sel, instance, before, after, arg(id, 2); arg(id, 3); arg(id, 4); arg(id, 5); arg(id, 6)) break;

        default:
            NSAssert(0, @"暂不支持更多参数");
            break;
    }
}

@end
