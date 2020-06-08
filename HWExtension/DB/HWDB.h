//
//  HWDB.h
//  HWDatabase
//
//  Created by Wang,Houwen on 2018/11/18.
//  Copyright © 2018 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Category.h"
#import "NSString+SQL.h"
#import "HWDBTypes.h"

@class FMDatabaseQueue, FMResultSet;

NS_ASSUME_NONNULL_BEGIN

@interface HWDB : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, strong, readonly) FMDatabaseQueue *dbQueue;

@property (nonatomic, copy, readonly) NSArray<NSString *> *tables;

+ (instancetype)dbWithPath:(NSString *)path;

- (void)close;

// 表是否存在
- (BOOL)tableExists:(NSString *)name;

// 建表, 如果已存在，直接返回YES
- (BOOL)creatTable:(NSString *)name columns:(NSArray<HWDBColumnInfo *> *)columns error:(NSError **)error;

// 删表
- (BOOL)removeTable:(NSString *)name error:(NSError **)error;

// 所有字段
- (NSArray<HWDBColumnInfo *> *)columnsInTable:(NSString *)name;

// 插入
- (BOOL)insertRowWithColumns:(NSArray<HWDBColumn *> *)columns
                     inTable:(NSString *)name
           unsupportedValues:(nullable id (^)(NSString *key, id value))unsupported
                       error:(NSError **)error;

// 更新
- (BOOL)updateRowsWithColumns:(NSArray<HWDBColumn *> *)columns
                      inTable:(NSString *)name
            unsupportedValues:(nullable id (^)(NSString *key, id value))unsupported
                        where:(nullable NSString *)where
                        error:(NSError **)error;

// 查询
- (NSArray<NSDictionary<NSString *, id> *> *)selectRowsWhere:(nullable NSString *)where
                                                     groupBy:(nullable NSArray<NSString *> *)groupColumns
                                                     orderBy:(nullable NSArray<NSString *> *)orderColumns
                                                       limit:(NSInteger)limit
                                                     inTable:(NSString *)name
                                                convertValue:(nullable id (^)(NSString *key, id oldValue))convert
                                                       error:(NSError **)error;

// 删数据
- (BOOL)deleteRowsWhere:(nullable NSString *)where inTable:(NSString *)name error:(NSError **)error;

// 字段是否存在
- (BOOL)columnExists:(NSString *)columnName inTable:(NSString *)name;

// 加字段
- (BOOL)addColumns:(HWDBColumnInfo *)columnInfo inTable:(NSString *)name error:(NSError **)error;

// update, empty value use [NSNull null]
- (BOOL)executeUpdate:(NSString *)sql values:(nullable NSArray *)values error:(NSError *__autoreleasing *)error;

// query
- (FMResultSet *)executeQuery:(NSString *)sql values:(nullable NSArray *)values error:(NSError *__autoreleasing *)error;

@end

@interface HWDB (ValueSupport)

+ (BOOL)SQLiteSupportedValue:(id)value;
+ (nullable HWSQLiteDataType)SQLiteDataTypeForValue:(id)value;                     // return `nil` if value not supported
+ (nullable HWSQLiteDataType)SQLiteDataTypeForProperty:(HWPropertyInfo *)property; // return `nil` if property not supported

@end

NS_ASSUME_NONNULL_END
