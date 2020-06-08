//
//  HWDBTypes.h
//  HWDatabase
//
//  Created by Wang,Houwen on 2018/11/18.
//  Copyright © 2018 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *HWSQLiteDataType NS_EXTENSIBLE_STRING_ENUM;
typedef NSString *HWColumnConstraint NS_EXTENSIBLE_STRING_ENUM;

/*
 *  SQLite data types
 */
extern HWSQLiteDataType const HWSQLiteDataTypeNone;    // None
extern HWSQLiteDataType const HWSQLiteDataTypeBool;    // BOOL
extern HWSQLiteDataType const HWSQLiteDataTypeInt;     // int
extern HWSQLiteDataType const HWSQLiteDataTypeInteger; // NSInteger
extern HWSQLiteDataType const HWSQLiteDataTypeLong;    // long

extern HWSQLiteDataType const HWSQLiteDataTypeDouble; // double
extern HWSQLiteDataType const HWSQLiteDataTypeReal;   // double

extern HWSQLiteDataType const HWSQLiteDataTypeNumber;        // NSNumber
extern HWSQLiteDataType const HWSQLiteDataTypeDecimalNumber; // NSDecimalNumber

extern HWSQLiteDataType const HWSQLiteDataTypeChar;          // char
extern HWSQLiteDataType const HWSQLiteDataTypeString;        // NSString
extern HWSQLiteDataType const HWSQLiteDataTypeText;          // NSString
extern HWSQLiteDataType const HWSQLiteDataTypeMutableString; // NSMutableString

extern HWSQLiteDataType const HWSQLiteDataTypeData; // NSData

extern HWSQLiteDataType const HWSQLiteDataTypeDate;     // NSDate e.g.YYYY-MM-dd
extern HWSQLiteDataType const HWSQLiteDataTypeTime;     // NSDate e.g.HH:mm:ss
extern HWSQLiteDataType const HWSQLiteDataTypeDateTime; // NSDate e.g.YYYY-MM-dd HH:mm:ss

/*
 *  SQLite data constraint
 *      NOT NULL            - 非空
 *      UNIQUE              - 唯一
 *      PRIMARY KEY         - 主键
 *      AUTOINCREATEMENT    - 自增
 *      FOREIGN KEY         - 外键
 *      CHECK               - 条件检查，确保一列中的所有值满足一定条件
 *      DEFAULT             - 默认值
 */
extern HWColumnConstraint const HWColumnConstraintNotNull;       // NOT NULL
extern HWColumnConstraint const HWColumnConstraintUnique;        // UNIQUE
extern HWColumnConstraint const HWColumnConstraintPrimaryKey;    // PRIMARY KEY
extern HWColumnConstraint const HWColumnConstraintAutoIncrement; // AUTOINCREMENT

// FOREIGN KEY
extern HWColumnConstraint const HWColumnConstraintForeignKey(NSString *columnName,
                                                             NSString *otherTableName,
                                                             NSString *otherColumnName);
// CHECK
extern HWColumnConstraint const HWColumnConstraintCheck(NSString *check);

// DEFAULT
extern HWColumnConstraint const HWColumnConstraintDefault(NSString *defaultValue);

@interface HWDBColumnInfo : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) HWSQLiteDataType dataType;               // default `HWSQLiteDataTypeNone`
@property (nonatomic, copy, readonly) NSArray<HWColumnConstraint> *constraint; // default `nil`, e.g. PRIMARY KEY、AUTOINCREMENT、NOT NULL、UNIQUE...

@property (nonatomic, copy, readonly) NSString *columnInfoSQL;

+ (instancetype)columnInfoWithName:(NSString *)name dataType:(HWSQLiteDataType)type constraint:(nullable NSArray<HWColumnConstraint> *)constraint;

@end

@interface HWDBColumn : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) id value;

+ (instancetype)columnWithName:(NSString *)name value:(id)value;

@end

NS_ASSUME_NONNULL_END
