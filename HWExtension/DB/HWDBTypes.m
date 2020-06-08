//
//  HWDBTypes.m
//  HWDatabase
//
//  Created by Wang,Houwen on 2018/11/18.
//  Copyright © 2018 Wang,Houwen. All rights reserved.
//

#import "HWDBTypes.h"

#pragma mark -

/*
 *  SQLite data types
 */
HWSQLiteDataType const HWSQLiteDataTypeNone = @"NONE";
HWSQLiteDataType const HWSQLiteDataTypeBool = @"BOOLEAN";
HWSQLiteDataType const HWSQLiteDataTypeInt = @"INT";
HWSQLiteDataType const HWSQLiteDataTypeInteger = @"INTEGER";
HWSQLiteDataType const HWSQLiteDataTypeLong = @"BIGINT";

HWSQLiteDataType const HWSQLiteDataTypeDouble = @"DOUBLE";
HWSQLiteDataType const HWSQLiteDataTypeReal = @"REAL";

HWSQLiteDataType const HWSQLiteDataTypeNumber = @"NUMERIC";
HWSQLiteDataType const HWSQLiteDataTypeDecimalNumber = @"DECIMAL";

HWSQLiteDataType const HWSQLiteDataTypeChar = @"CHAR";
HWSQLiteDataType const HWSQLiteDataTypeString = @"STRING";
HWSQLiteDataType const HWSQLiteDataTypeText = @"TEXT";
HWSQLiteDataType const HWSQLiteDataTypeMutableString = @"VARCHAR";

HWSQLiteDataType const HWSQLiteDataTypeData = @"BLOB";

HWSQLiteDataType const HWSQLiteDataTypeDate = @"DATE";
HWSQLiteDataType const HWSQLiteDataTypeTime = @"TIME";
HWSQLiteDataType const HWSQLiteDataTypeDateTime = @"DATETIME";

/*
 *  SQLite data constraint
 */
HWColumnConstraint const HWColumnConstraintNotNull = @"NOT NULL";            // NOT NULL
HWColumnConstraint const HWColumnConstraintUnique = @"UNIQUE";               // UNIQUE
HWColumnConstraint const HWColumnConstraintPrimaryKey = @"PRIMARY KEY";      // PRIMARY KEY
HWColumnConstraint const HWColumnConstraintAutoIncrement = @"AUTOINCREMENT"; // AUTOINCREMENT

// FOREIGN KEY
HWColumnConstraint const HWColumnConstraintForeignKey(NSString *columnName,
                                                      NSString *otherTableName,
                                                      NSString *otherColumnName) {
    return [NSString stringWithFormat:@"FOREIGN KEY (%@) REFERENCES %@(%@)",
                                      columnName,
                                      otherTableName,
                                      otherColumnName];
}

// CHECK
HWColumnConstraint const HWColumnConstraintCheck(NSString *check) {
    return [NSString stringWithFormat:@"CHECK(%@)", check];
};

// DEFAULT
HWColumnConstraint const HWColumnConstraintDefault(NSString *defaultValue) {
    return [NSString stringWithFormat:@"DEFAULT %@", defaultValue];
};

@interface HWDBColumnInfo ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) HWSQLiteDataType dataType;
@property (nonatomic, copy) NSArray<HWColumnConstraint> *constraint;
@end

@implementation HWDBColumnInfo

- (instancetype)init {
    if (self = [super init]) {
        _dataType = HWSQLiteDataTypeNone;
    }
    return self;
}

+ (instancetype)columnInfoWithName:(NSString *)name dataType:(HWSQLiteDataType)type constraint:(nullable NSArray<HWColumnConstraint> *)constraint {
    HWDBColumnInfo *info = [[self alloc] init];
    info.name = name;
    info.dataType = type;
    info.constraint = constraint;
    return info;
}

- (NSString *)columnInfoSQL {
    return [NSString stringWithFormat:@"'%@' %@ %@", _name, (_dataType ?: @""), (_constraint.count ? [_constraint componentsJoinedByString:@" "] : @"")];
}

@end

@interface HWDBColumn ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) id value;
@end

@implementation HWDBColumn

+ (instancetype)columnWithName:(NSString *)name value:(id)value {
    HWDBColumn *c = [[self alloc] init];
    c.name = name;
    c.value = value;
    return c;
}

@end
