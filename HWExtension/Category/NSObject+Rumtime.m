//
//  NSObject+Rumtime.m
//  HWRuntime_Example
//
//  Created by Wang,Houwen on 2019/8/17.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import "NSObject+Rumtime.h"

static HWPropertyDataType propertyType(const char *cType) {
    static NSDictionary<NSString *, NSNumber *> *propertyTypeMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertyTypeMap = @{ @"" : @(HWPropertyDataTypeUnknown),
                             @"B" : @(HWPropertyDataTypeBool),
                             @"c" : @(HWPropertyDataTypeChar),
                             @"C" : @(HWPropertyDataTypeUChar),
                             @"*" : @(HWPropertyDataTypeCharPointer),
                             @"s" : @(HWPropertyDataTypeShort),
                             @"S" : @(HWPropertyDataTypeUShort),
                             @"i" : @(HWPropertyDataTypeInt),
                             @"I" : @(HWPropertyDataTypeUInt),
                             @"f" : @(HWPropertyDataTypeFloat),
                             @"d" : @(HWPropertyDataTypeDouble),
                             @"l" : @(HWPropertyDataTypeLong),
                             @"L" : @(HWPropertyDataTypeULong),
                             @"q" : @(HWPropertyDataTypeLongLong),
                             @"Q" : @(HWPropertyDataTypeULongLong),
                             @"v" : @(HWPropertyDataTypeVoid),
                             @"@" : @(HWPropertyDataTypeId),
                             @"\"" : @(HWPropertyDataTypeObject),
                             @"#" : @(HWPropertyDataTypeClass),
                             @":" : @(HWPropertyDataTypeSEL),
                             @"?" : @(HWPropertyDataTypeIMP),
                             @"}" : @(HWPropertyDataTypeStruct),
        };
    });

    HWPropertyDataType pType = HWPropertyDataTypeUnknown;
    NSString *type = [NSString stringWithUTF8String:cType];
    if (type.length) {
        NSString *lastKey = [type substringFromIndex:type.length - 1];
        if ([propertyTypeMap.allKeys containsObject:lastKey]) {
            pType = propertyTypeMap[lastKey].integerValue;
        }
        if (pType == HWPropertyDataTypeVoid && [type hasPrefix:@"^"]) {
            pType = HWPropertyDataTypeVoidPointer;
        } else if (pType == HWPropertyDataTypeStruct && [type hasPrefix:@"^"]) {
            pType = HWPropertyDataTypeStructPointer;
        }
    }
    return pType;
}

#pragma mark - ///////////////////////////////////////////////////////////////////

#define __DescriptionIMP                                                                                         \
    -(NSString *)description {                                                                                   \
        NSMutableDictionary *kvs = [NSMutableDictionary dictionary];                                             \
        [propertyListEndOfClass(self.class, [NSObject class]) enumerateObjectsUsingBlock:^(HWPropertyInfo * obj, \
                                                                                           NSUInteger idx,       \
                                                                                           BOOL * stop) {        \
            id v = [self valueForKey:obj.name];                                                                  \
            kvs[obj.name] = v;                                                                                   \
        }];                                                                                                      \
        return [kvs description];                                                                                \
    }

#define __NSCopyingIMP                                                                                   \
    -(id)copyWithZone : (NSZone *)zone {                                                                 \
        id copy = [self.class allocWithZone:zone];                                                       \
        [ivarListEndOfClass(self.class, [NSObject class]) enumerateObjectsUsingBlock:^(HWIvarInfo * obj, \
                                                                                       NSUInteger idx,   \
                                                                                       BOOL * stop) {    \
            id value = [self valueForKey:obj.name];                                                      \
            !value ?: [copy setValue:value forKey:obj.name];                                             \
        }];                                                                                              \
        return copy;                                                                                     \
    }

#define __NSMutableCopyingIMP                   \
    -(id)mutableCopyWithZone : (NSZone *)zone { \
        return [self copyWithZone:zone];        \
    }

#define __NSCodingIMP                                                                                    \
    -(instancetype)initWithCoder : (NSCoder *)aDecoder {                                                 \
        [ivarListEndOfClass(self.class, [NSObject class]) enumerateObjectsUsingBlock:^(HWIvarInfo * obj, \
                                                                                       NSUInteger idx,   \
                                                                                       BOOL * stop) {    \
            if (![obj.name isEqualToString:@"_cls"] && ![obj.name isEqualToString:@"_superCls"]) {       \
                id value = [aDecoder decodeObjectForKey:obj.name];                                       \
                !value ?: [self setValue:value forKey:obj.name];                                         \
            }                                                                                            \
        }];                                                                                              \
        return self;                                                                                     \
    }                                                                                                    \
    -(void)encodeWithCoder : (NSCoder *)aCoder {                                                         \
        [ivarListEndOfClass(self.class, [NSObject class]) enumerateObjectsUsingBlock:^(HWIvarInfo * obj, \
                                                                                       NSUInteger idx,   \
                                                                                       BOOL * stop) {    \
            if (![obj.name isEqualToString:@"_cls"] && ![obj.name isEqualToString:@"_superCls"]) {       \
                id value = [self valueForKey:obj.name];                                                  \
                !value ?: [aCoder encodeObject:value forKey:obj.name];                                   \
            }                                                                                            \
        }];                                                                                              \
    }

@implementation NSObject (Runtime)

+ (void)exchangeImplementations:(SEL)selfSEL1 otherMethod:(SEL)selfSEL2 isInstance:(BOOL)isInstance {
    if (!sel_isEqual(selfSEL1, selfSEL2)) {
        Method method1, method2;
        if (isInstance) {
            method1 = class_getInstanceMethod(self, selfSEL1);
            method2 = class_getInstanceMethod(self, selfSEL2);
        } else {
            method1 = class_getClassMethod(self, selfSEL1);
            method2 = class_getClassMethod(self, selfSEL2);
        }
        [self exchangeImplementations:method1 otherMethod:method2];
    }
}

+ (void)exchangeImplementations:(Method)method otherMethod:(Method)otherMethod {
    method_exchangeImplementations(method, otherMethod);
}

@end

@interface HWIvarInfo ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *typeEncoding;
@property (nonatomic, assign) size_t size;
@property (nonatomic, assign) ptrdiff_t offset;
@end

@implementation HWIvarInfo
__DescriptionIMP;
__NSCopyingIMP;
__NSMutableCopyingIMP;
__NSCodingIMP;
@end

@interface HWPropertyAttributeInfo ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@end

@implementation HWPropertyAttributeInfo
__DescriptionIMP;
__NSCopyingIMP;
__NSMutableCopyingIMP;
__NSCodingIMP;
@end

@interface HWPropertyInfo ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ivarName;                   // 对应的实例变量名字
@property (nonatomic, copy) NSString *getterMethod;               // getter
@property (nonatomic, copy) NSString *setterMethod;               // setter
@property (nonatomic, assign) HWPropertyRefType refType;          // 引用类型
@property (nonatomic, assign) HWPropertyDataType dataType;        // 数据类型
@property (nonatomic, assign, getter=isNonatomic) BOOL nonatomic; // 原子属性
@property (nonatomic, assign, getter=isReadonly) BOOL readonly;   // 是否只读
@property (nonatomic, assign) Class cls;                          // 如果是对象有值
@property (nonatomic, assign) BOOL isBasicPointer;                // 是否是基础数据类型指针 (char *、BOOL *、int *、struct * ...)
@property (nonatomic, copy) NSString *attributes;
@property (nonatomic, copy) NSArray<HWPropertyAttributeInfo *> *attributeList;
@property (nonatomic, assign) const objc_property_attribute_t *attribute_t;
@end

@implementation HWPropertyInfo
__DescriptionIMP;
__NSCopyingIMP;
__NSMutableCopyingIMP;
__NSCodingIMP;
@end

@interface HWMethodInfo ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *typeEncoding;
@property (nonatomic, copy) NSString *returnType;
@property (nonatomic, assign) unsigned int numberOfArguments;
@property (nonatomic, copy) NSArray<NSString *> *argumentTypes;
@property (nonatomic, assign) IMP implementation;
@end

@implementation HWMethodInfo
__DescriptionIMP;
__NSCopyingIMP;
__NSMutableCopyingIMP;
__NSCodingIMP;
@end

@interface HWProtocolInfo ()
@property (nonatomic, copy) NSString *name;
@end

@implementation HWProtocolInfo
__DescriptionIMP;
__NSCopyingIMP;
__NSMutableCopyingIMP;
__NSCodingIMP;
@end

@interface HWClassInfo ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isMetaClass;
@property (nonatomic, assign) int version;
@property (nonatomic, assign) Class cls;      // class
@property (nonatomic, assign) Class superCls; // super class
@property (nonatomic, assign) size_t instanceSize;
@property (nonatomic, copy) NSArray<HWIvarInfo *> *ivarList;
@property (nonatomic, copy) NSArray<HWPropertyInfo *> *propertyList;
@property (nonatomic, copy) NSArray<HWProtocolInfo *> *protocolList;
@property (nonatomic, copy) NSArray<HWMethodInfo *> *classMethodList;
@property (nonatomic, copy) NSArray<HWMethodInfo *> *instanceMethodList;
@end

@implementation HWClassInfo
__DescriptionIMP;
__NSCopyingIMP;
__NSMutableCopyingIMP;
__NSCodingIMP;
@end

static HWProtocolInfo *
protocolInfo(Protocol *protocol) {
    if (protocol != NULL) {
        HWProtocolInfo *info = [[HWProtocolInfo alloc] init];
        info.name = [NSString stringWithUTF8String:protocol_getName(protocol)];
        return info;
    }
    return nil;
}

static HWPropertyAttributeInfo *attributeInfo(objc_property_attribute_t att) {
    HWPropertyAttributeInfo *info = [[HWPropertyAttributeInfo alloc] init];
    info.name = [NSString stringWithUTF8String:att.name];
    info.value = [NSString stringWithUTF8String:att.value];
    return info;
}

static HWIvarInfo *ivarInfo(Ivar ivar) {
    if (ivar != NULL) {
        HWIvarInfo *info = [[HWIvarInfo alloc] init];
        info.name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        info.typeEncoding = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        info.offset = ivar_getOffset(ivar);
        return info;
    }
    return nil;
}

static HWPropertyInfo *propertyInfo(objc_property_t property) {
    if (property != NULL) {
        __block HWPropertyInfo *info = [[HWPropertyInfo alloc] init];
        info.dataType = HWPropertyDataTypeUnknown;
        info.refType = HWPropertyRefTypeAssign;

        /* name */
        info.name = [NSString stringWithUTF8String:property_getName(property)];
        info.getterMethod = [info.name copy];
        info.setterMethod = [info.name copy];
        info.attributes = [NSString stringWithUTF8String:property_getAttributes(property)];

        unsigned int count;
        objc_property_attribute_t *attList = property_copyAttributeList(property, &count);
        info.attribute_t = attList;

        NSMutableArray *attInfoList = [NSMutableArray array];
        for (int i = 0; i < count; i++) {
            objc_property_attribute_t att = attList[i];
            HWPropertyAttributeInfo *info = attributeInfo(att);
            [attInfoList addObject:info];
        }
        info.attributeList = [attInfoList copy];

        [info.attributeList enumerateObjectsUsingBlock:^(HWPropertyAttributeInfo *obj,
                                                         NSUInteger idx,
                                                         BOOL *stop) {
            /* type */
            if ([obj.name isEqualToString:@"T"]) {
                info.dataType = propertyType(obj.value.UTF8String);
                if (info.dataType == HWPropertyDataTypeObject) {
                    info.cls = NSClassFromString([[obj.value substringToIndex:obj.value.length - 1] substringFromIndex:2]);
                } else if (info.dataType != HWPropertyDataTypeClass &&
                           info.dataType != HWPropertyDataTypeSEL &&
                           info.dataType != HWPropertyDataTypeIMP) {
                    info.isBasicPointer = ([obj.value hasPrefix:@"^"] || [obj.value hasPrefix:@"*"]);
                }
            }
            /* refType */
            else if ([obj.name isEqualToString:@"&"]) {
                info.refType = HWPropertyRefTypeStrong;
            } else if ([obj.name isEqualToString:@"C"]) {
                info.refType = HWPropertyRefTypeCopy;
            } else if ([obj.name isEqualToString:@"W"]) {
                info.refType = HWPropertyRefTypeWeak;
            }
            /* other */
            else if ([obj.name isEqualToString:@"R"]) {
                info.readonly = YES;
            } else if ([obj.name isEqualToString:@"N"]) {
                info.nonatomic = YES;
            } else if ([obj.name isEqualToString:@"V"]) {
                info.ivarName = obj.value;
            } else if ([obj.name isEqualToString:@"G"]) {
                info.getterMethod = obj.value;
            } else if ([obj.name isEqualToString:@"S"]) {
                info.setterMethod = obj.value;
            }
        }];
        return info;
    }
    return nil;
}

static HWMethodInfo *methodInfo(Method method) {
    if (method != NULL) {
        HWMethodInfo *info = [[HWMethodInfo alloc] init];
        info.name = NSStringFromSelector(method_getName(method));
        info.returnType = [NSString stringWithUTF8String:method_copyReturnType(method)];
        info.numberOfArguments = method_getNumberOfArguments(method);
        info.typeEncoding = [NSString stringWithUTF8String:method_getTypeEncoding(method)];
        info.implementation = method_getImplementation(method);

        NSMutableArray *types = [NSMutableArray array];
        for (int i = 0; i < info.numberOfArguments; i++) {
            NSString *type = [NSString stringWithUTF8String:method_copyArgumentType(method, i)];
            [types addObject:type];
        }
        info.argumentTypes = types;
        return info;
    }
    return nil;
}

HWClassInfo *classInfo(Class cls) {
    if (cls != NULL) {
        HWClassInfo *classInfo = [[HWClassInfo alloc] init];

        classInfo.cls = cls;
        classInfo.name = [NSString stringWithUTF8String:class_getName(cls)];
        classInfo.isMetaClass = class_isMetaClass(cls);
        classInfo.superCls = class_getSuperclass(cls);
        classInfo.version = class_getVersion(cls);
        classInfo.instanceSize = class_getInstanceSize(cls);

        classInfo.ivarList = ivarList(cls);
        classInfo.propertyList = propertyList(cls);
        classInfo.protocolList = protocolList(cls);
        classInfo.instanceMethodList = methodList(cls);

        Class metaCls = object_getClass(cls);
        if (metaCls) {
            classInfo.classMethodList = methodList(metaCls);
        }
        return classInfo;
    }
    return nil;
}

// 递归遍历superclass
void recursionSuperclassUsingBlock(Class from, void(NS_NOESCAPE ^ block)(Class cls, BOOL *stop)) {
    if (from && block) {
        BOOL stop = NO;
        Class cls_t = from;
        do {
            block(cls_t, &stop);
            if (stop)
                break;
            cls_t = class_getSuperclass(cls_t);
        } while (cls_t);
    }
}

#pragma mark - ///////////////////////////////////////////////////////////////////

NSArray<HWClassInfo *> *registeredClassList(void) {
    unsigned int count = 0;
    Class *list = objc_copyClassList(&count);
    NSMutableArray<HWClassInfo *> *infos = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        Class s = list[i];
        HWClassInfo *info = classInfo(s);
        [infos addObject:info];
    }
    free(list);
    return [infos copy];
}

NSArray<HWProtocolInfo *> *protocolList(Class cls) {
    unsigned int count = 0;
    Protocol *__unsafe_unretained _Nonnull *_Nullable list = class_copyProtocolList(cls, &count);
    NSMutableArray<HWProtocolInfo *> *result = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        Protocol *p = list[i];
        HWProtocolInfo *info = protocolInfo(p);
        [result addObject:info];
    }
    free(list);
    return [result copy];
}

NSArray<HWProtocolInfo *> *protocolListEndOfClass(Class from, Class end) {
    NSMutableArray<HWProtocolInfo *> *result = [NSMutableArray array];
    recursionSuperclassUsingBlock(from, ^(__unsafe_unretained Class cls, BOOL *stop) {
        if (![cls isEqual:end]) {
            [result addObjectsFromArray:protocolList(cls)];
        } else {
            *stop = YES;
        }
    });
    return [result copy];
}

NSArray<HWPropertyInfo *> *propertyList(Class cls) {
    unsigned int count = 0;
    objc_property_t *list = class_copyPropertyList(cls, &count);
    NSMutableArray<HWPropertyInfo *> *result = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        objc_property_t p = list[i];
        HWPropertyInfo *info = propertyInfo(p);
        [result addObject:info];
    }
    free(list);
    return [result copy];
}

NSArray<HWPropertyInfo *> *propertyListEndOfClass(Class from, Class end) {
    NSMutableArray<HWPropertyInfo *> *result = [NSMutableArray array];
    recursionSuperclassUsingBlock(from, ^(__unsafe_unretained Class cls, BOOL *stop) {
        if (![cls isEqual:end]) {
            [result addObjectsFromArray:propertyList(cls)];
        } else {
            *stop = YES;
        }
    });
    return [result copy];
}

NSArray<HWIvarInfo *> *ivarList(Class cls) {
    unsigned int count = 0;
    Ivar *list = class_copyIvarList(cls, &count);
    NSMutableArray<HWIvarInfo *> *result = [NSMutableArray array];

    for (int i = 0; i < count; i++) {
        Ivar v = list[i];
        HWIvarInfo *info = ivarInfo(v);
        if (i > 0) {
            HWIvarInfo *before = result[i - 1];
            before.size = info.offset - before.offset;
        }
        if (i == count - 1) {
            info.size = sizeof(id);
        }

        [result addObject:info];
    }
    free(list);
    return [result copy];
}

NSArray<HWIvarInfo *> *ivarListEndOfClass(Class from, Class end) {
    NSMutableArray<HWIvarInfo *> *result = [NSMutableArray array];
    recursionSuperclassUsingBlock(from, ^(__unsafe_unretained Class cls, BOOL *stop) {
        if (![cls isEqual:end]) {
            [result addObjectsFromArray:ivarList(cls)];
        } else {
            *stop = YES;
        }
    });
    return [result copy];
}

NSArray<HWMethodInfo *> *methodList(Class cls) {
    unsigned int count = 0;
    Method *list = class_copyMethodList(cls, &count);
    NSMutableArray<HWMethodInfo *> *result = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        Method m = list[i];
        [result addObject:methodInfo(m)];
    }
    free(list);
    return [result copy];
}

NSArray<HWMethodInfo *> *methodListEndOfClass(Class from, Class end) {
    NSMutableArray<HWMethodInfo *> *result = [NSMutableArray array];
    recursionSuperclassUsingBlock(from, ^(__unsafe_unretained Class cls, BOOL *stop) {
        if (![cls isEqual:end]) {
            [result addObjectsFromArray:methodList(cls)];
        } else {
            *stop = YES;
        }
    });
    return [result copy];
}

#pragma mark - ///////////////////////////////////////////////////////////////////

NSArray<NSString *> *registeredClassNameList(void) {
    NSMutableArray<NSString *> *list = [NSMutableArray array];
    [registeredClassList() enumerateObjectsUsingBlock:^(HWClassInfo *obj, NSUInteger idx, BOOL *stop) {
        [list addObject:obj.name];
    }];
    return [list copy];
}

NSArray<NSString *> *protocolNameList(Class cls) {
    NSMutableArray<NSString *> *list = [NSMutableArray array];
    [protocolList(cls) enumerateObjectsUsingBlock:^(HWProtocolInfo *obj, NSUInteger idx, BOOL *stop) {
        [list addObject:obj.name];
    }];
    return [list copy];
}

NSArray<NSString *> *protocolNameListEndOfClass(Class from, Class end) {
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    [protocolListEndOfClass(from, end) enumerateObjectsUsingBlock:^(HWProtocolInfo *obj, NSUInteger idx, BOOL *stop) {
        [result addObject:obj.name];
    }];
    return [result copy];
}

NSArray<NSString *> *propertyNameList(Class cls) {
    NSMutableArray<NSString *> *list = [NSMutableArray array];
    [propertyList(cls) enumerateObjectsUsingBlock:^(HWPropertyInfo *obj, NSUInteger idx, BOOL *stop) {
        [list addObject:obj.name];
    }];
    return [list copy];
}

NSArray<NSString *> *propertyNameListEndOfClass(Class from, Class end) {
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    [propertyListEndOfClass(from, end) enumerateObjectsUsingBlock:^(HWPropertyInfo *obj, NSUInteger idx, BOOL *stop) {
        [result addObject:obj.name];
    }];
    return [result copy];
}

NSArray<NSString *> *ivarNameList(Class cls) {
    NSMutableArray<NSString *> *list = [NSMutableArray array];
    [ivarList(cls) enumerateObjectsUsingBlock:^(HWIvarInfo *obj, NSUInteger idx, BOOL *stop) {
        [list addObject:obj.name];
    }];
    return [list copy];
}

NSArray<NSString *> *ivarListNameEndOfClass(Class from, Class end) {
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    [ivarListEndOfClass(from, end) enumerateObjectsUsingBlock:^(HWIvarInfo *obj, NSUInteger idx, BOOL *stop) {
        [result addObject:obj.name];
    }];
    return [result copy];
}

NSArray<NSString *> *methodNameList(Class cls) {
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    [methodList(cls) enumerateObjectsUsingBlock:^(HWMethodInfo *obj, NSUInteger idx, BOOL *stop) {
        [result addObject:obj.name];
    }];
    return [result copy];
}

NSArray<NSString *> *methodNameListEndOfClass(Class from, Class end) {
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    [methodListEndOfClass(from, end) enumerateObjectsUsingBlock:^(HWMethodInfo *obj, NSUInteger idx, BOOL *stop) {
        [result addObject:obj.name];
    }];
    return [result copy];
}

/* Adding Classes */

Class allocateClass(Class superclass, const char *name) {
    return objc_allocateClassPair(superclass, name, 0);
}

void registerClass(Class cls) {
    objc_registerClassPair(cls);
}

BOOL addMethod(Class cls, SEL name, IMP imp, const char *types) {
    return class_addMethod(cls, name, imp, types);
}

BOOL addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount) {
    return class_addProperty(cls, name, attributes, attributeCount);
}

BOOL addIvar(Class cls, const char *name, size_t size, uint8_t alignment, const char *types) {
    return class_addIvar(cls, name, size, alignment, types);
}

BOOL addProtocol(Class cls, Protocol *protocol) {
    return class_addProtocol(cls, protocol);
}

BOOL registerClassFromInfo(HWClassInfo *info) {
    if (info) {
        Class cls = allocateClass(info.superCls, info.name.UTF8String);
        if (cls != NULL) {
            [info.classMethodList enumerateObjectsUsingBlock:^(HWMethodInfo *obj, NSUInteger idx, BOOL *stop) {
                addMethod(objc_getMetaClass(info.name.UTF8String), NSSelectorFromString(obj.name), obj.implementation, obj.typeEncoding.UTF8String);
            }];

            [info.instanceMethodList enumerateObjectsUsingBlock:^(HWMethodInfo *obj, NSUInteger idx, BOOL *stop) {
                addMethod(info.cls, NSSelectorFromString(obj.name), obj.implementation, obj.typeEncoding.UTF8String);
            }];

            [info.propertyList enumerateObjectsUsingBlock:^(HWPropertyInfo *obj, NSUInteger idx, BOOL *stop) {
                addProperty(info.cls, obj.name.UTF8String, obj.attribute_t, (unsigned int)obj.attributeList.count);
            }];

            [info.ivarList enumerateObjectsUsingBlock:^(HWIvarInfo *obj, NSUInteger idx, BOOL *stop) {
                addIvar(info.cls, obj.name.UTF8String, obj.size, log2(obj.size), obj.typeEncoding.UTF8String);
            }];
            registerClass(cls);
        }
    }
    return NO;
}
