//
//  NSObject+Rumtime.h
//  HWRuntime_Example
//
//  Created by Wang,Houwen on 2019/8/17.
//  Copyright © 2019 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

@class HWClassInfo, HWProtocolInfo, HWMethodInfo, HWPropertyInfo, HWIvarInfo;

//  属性引用类型
typedef NS_ENUM(NSInteger, HWPropertyRefType) {
    HWPropertyRefTypeAssign, // assign
    HWPropertyRefTypeWeak,   // weak
    HWPropertyRefTypeStrong, // strong / retain
    HWPropertyRefTypeCopy,   // copy
};

// 属性数据类型
typedef NS_ENUM(NSInteger, HWPropertyDataType) {
    /* unknown */
    HWPropertyDataTypeUnknown,
    /* basic data type */
    HWPropertyDataTypeBool,          // BOOL
    HWPropertyDataTypeChar,          // char
    HWPropertyDataTypeUChar,         // unsigned char
    HWPropertyDataTypeCharPointer,   // char * / unsigned char *
    HWPropertyDataTypeShort,         // short
    HWPropertyDataTypeUShort,        // unsigned short
    HWPropertyDataTypeInt,           // int
    HWPropertyDataTypeUInt,          // unsigned int
    HWPropertyDataTypeFloat,         // float
    HWPropertyDataTypeDouble,        // double
    HWPropertyDataTypeLong,          // long / NSInteger
    HWPropertyDataTypeULong,         // unsigned long / NSUInteger
    HWPropertyDataTypeLongLong,      // long long
    HWPropertyDataTypeULongLong,     // unsigned long long
    HWPropertyDataTypeStruct,        // struct
    HWPropertyDataTypeStructPointer, // struct *
    /* other data type */
    HWPropertyDataTypeVoid,        // void
    HWPropertyDataTypeVoidPointer, // void *
    HWPropertyDataTypeId,          // id
    HWPropertyDataTypeObject,      // NSObject or subclass
    HWPropertyDataTypeClass,       // Class
    HWPropertyDataTypeSEL,         // SEL
    HWPropertyDataTypeIMP,         // IMP
};

NSArray<HWClassInfo *> *registeredClassList(void);
NSArray<NSString *> *registeredClassNameList(void);

NSArray<HWProtocolInfo *> *protocolList(Class cls);
NSArray<HWProtocolInfo *> *protocolListEndOfClass(Class from, Class end);
NSArray<NSString *> *protocolNameList(Class cls);
NSArray<NSString *> *protocolNameListEndOfClass(Class from, Class end);

NSArray<HWPropertyInfo *> *propertyList(Class cls);
NSArray<HWPropertyInfo *> *propertyListEndOfClass(Class from, Class end);
NSArray<NSString *> *propertyNameList(Class cls);
NSArray<NSString *> *propertyNameListEndOfClass(Class from, Class end);

NSArray<HWIvarInfo *> *ivarList(Class cls);
NSArray<HWIvarInfo *> *ivarListEndOfClass(Class from, Class end);
NSArray<NSString *> *ivarNameList(Class cls);
NSArray<NSString *> *ivarListNameEndOfClass(Class from, Class end);

NSArray<HWMethodInfo *> *methodList(Class cls);
NSArray<HWMethodInfo *> *methodListEndOfClass(Class from, Class end);
NSArray<NSString *> *methodNameList(Class cls);
NSArray<NSString *> *methodNameListEndOfClass(Class from, Class end);

/* Adding Classes */
Class allocateClass(Class superclass, const char *name);
void registerClass(Class cls);
BOOL addMethod(Class cls, SEL name, IMP imp, const char *types);
BOOL addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount);
BOOL addIvar(Class cls, const char *name, size_t size, uint8_t alignment, const char *types);
BOOL addProtocol(Class cls, Protocol *protocol);
BOOL registerClassFromInfo(HWClassInfo *info);

@interface NSObject (Runtime)

+ (void)exchangeImplementations:(SEL)selfSEL1 otherMethod:(SEL)selfSEL2 isInstance:(BOOL)isInstance;
+ (void)exchangeImplementations:(Method)method otherMethod:(Method)otherMethod;

@end

#pragma mark - ivar info

@interface HWIvarInfo : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *typeEncoding;
@property (nonatomic, assign, readonly) size_t size;
@property (nonatomic, assign, readonly) ptrdiff_t offset;

@end

#pragma mark - property attribute info

@interface HWPropertyAttributeInfo : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *value;

@end

#pragma mark - property info

@interface HWPropertyInfo : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *ivarName;     // 对应的实例变量名字
@property (nonatomic, copy, readonly) NSString *getterMethod; // getter
@property (nonatomic, copy, readonly) NSString *setterMethod; // setter

@property (nonatomic, assign, readonly) HWPropertyRefType refType;   // 引用类型
@property (nonatomic, assign, readonly) HWPropertyDataType dataType; // 数据类型

@property (nonatomic, assign, getter=isNonatomic, readonly) BOOL nonatomic; // 原子属性
@property (nonatomic, assign, getter=isReadonly, readonly) BOOL readonly;   // 是否只读

@property (nonatomic, assign, readonly) Class cls;           // 如果是对象有值
@property (nonatomic, assign, readonly) BOOL isBasicPointer; // 是否是基础数据类型指针 (char *、BOOL *、int *、struct * ...)

@property (nonatomic, copy, readonly) NSString *attributes;
@property (nonatomic, copy, readonly) NSArray<HWPropertyAttributeInfo *> *attributeList;

@property (nonatomic, assign, readonly) const objc_property_attribute_t *attribute_t;

@end

#pragma mark - method info

@interface HWMethodInfo : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *typeEncoding;
@property (nonatomic, copy, readonly) NSString *returnType;
@property (nonatomic, assign, readonly) unsigned int numberOfArguments;
@property (nonatomic, copy, readonly) NSArray<NSString *> *argumentTypes;
@property (nonatomic, assign, readonly) IMP implementation;

@end

#pragma mark - protocol info

@interface HWProtocolInfo : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property (nonatomic, copy, readonly) NSString *name;

@end

#pragma mark - class info

@interface HWClassInfo : NSObject <NSCopying, NSMutableCopying, NSCoding>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL isMetaClass;
@property (nonatomic, assign, readonly) int version;
@property (nonatomic, assign, readonly) Class cls;      // class
@property (nonatomic, assign, readonly) Class superCls; // super class
@property (nonatomic, assign, readonly) size_t instanceSize;

@property (nonatomic, copy, readonly) NSArray<HWIvarInfo *> *ivarList;
@property (nonatomic, copy, readonly) NSArray<HWPropertyInfo *> *propertyList;
@property (nonatomic, copy, readonly) NSArray<HWProtocolInfo *> *protocolList;
@property (nonatomic, copy, readonly) NSArray<HWMethodInfo *> *classMethodList;
@property (nonatomic, copy, readonly) NSArray <HWMethodInfo *>*instanceMethodList;

@end

NS_ASSUME_NONNULL_END
