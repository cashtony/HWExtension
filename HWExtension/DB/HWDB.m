//
//  HWDB.m
//  HWDatabase
//
//  Created by Wang,Houwen on 2018/11/18.
//  Copyright © 2018 Wang,Houwen. All rights reserved.
//

#import "HWDB.h"
#import "FMDB.h"

@interface HWDB ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation HWDB

+ (instancetype)dbWithPath:(NSString *)path {
    HWDB *d = [[self alloc] init];
    d.path = path;
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path.stringByDeletingLastPathComponent isDirectory:&isDirectory];
    if (!isDirectory || !exists) {
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];

        if (!success) {
            return nil;
        }
    }
    d.dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    return d;
}

- (NSString *)name {
    return [_path lastPathComponent];
}

- (void)close {
    [_dbQueue close];
}

#pragma mark - table operation

- (BOOL)tableExists:(NSString *)name {
    __block BOOL flg = NO;
    [_dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
        flg = [db tableExists:name];
    }];
    return flg;
}

- (BOOL)creatTable:(NSString *)name columns:(NSArray<HWDBColumnInfo *> *)columns error:(NSError **)error {
    NSAssert(name.length, @"the table name can not be empty!!!");
    NSAssert(columns.count, @"the column count can not be 0!!!");
    NSString *sql = NSString.creatTable(name, [self.class columnInfos:columns]);
    return [self executeUpdate:sql values:nil error:error];
}

- (BOOL)removeTable:(NSString *)name error:(NSError **)error {
    return [self executeUpdate:NSString.drop(name) values:nil error:error];
}

- (NSArray<NSString *> *)tables {
    FMResultSet *result = [self executeQuery:NSString.select(@"name", @[ @"sqlite_master" ])
                                                 .where(@"type='table'")
                                                 .orderBy(@[ @"name" ])
                                      values:nil
                                       error:nil];

    NSMutableArray *array = [NSMutableArray array];
    while (result.next) {
        [array addObject:result.resultDictionary[@"name"]];
    }
    return [array copy];
}

- (NSArray<HWDBColumnInfo *> *)columnsInTable:(NSString *)name {
    // PRAGMA table_info(name)
    FMResultSet *result = [self executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)", name]
                                      values:nil
                                       error:nil];

    NSMutableArray<HWDBColumnInfo *> *array = [NSMutableArray array];

    while (result.next) {
        NSDictionary *dic = result.resultDictionary;
        NSString *cname = dic[@"name"];
        NSString *dataType = dic[@"type"];
        NSArray *constraint = nil;

        HWDBColumnInfo *info = [HWDBColumnInfo columnInfoWithName:cname
                                                         dataType:dataType
                                                       constraint:constraint];
        [array addObject:info];
    }

    return [array copy];
}

- (BOOL)insertRowWithColumns:(NSArray<HWDBColumn *> *)columns
                     inTable:(NSString *)name
           unsupportedValues:(nullable id (^)(NSString *key, id value))unsupported
                       error:(NSError **)error {
    NSAssert(name.length, @"the table name can not be empty!!!");

    if (columns.count) {
        NSMutableArray<NSString *> *columnNames = [NSMutableArray array];
        NSMutableArray<id> *columnValues = [NSMutableArray array];

        [columns enumerateObjectsUsingBlock:^(HWDBColumn *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {

            if (obj.name.length) {
                [columnNames addObject:obj.name];

                id value = obj.value;

                if (value == nil) {
                    value = [NSNull null];

                } else if (![self.class SQLiteSupportedValue:value]) {
                    if (unsupported) {
                        value = unsupported(obj.name, value);

                        if (![self.class SQLiteSupportedValue:value]) {
                            NSAssert(0, @"unsupported value : < %@ >", value);
                        }

                    } else {
                        NSAssert(0, @"unsupported value : < %@ >", value);
                    }
                }

                [columnValues addObject:value ?: [NSNull null]];
            }
        }];

        return [self executeUpdate:NSString.insert(name, columnNames) values:columnValues error:error];

    } else {
        return YES;
    }
}

- (BOOL)updateRowsWithColumns:(NSArray<HWDBColumn *> *)columns
                      inTable:(NSString *)name
            unsupportedValues:(nullable id (^)(NSString *key, id value))unsupported
                        where:(nullable NSString *)where
                        error:(NSError **)error {
    NSAssert(name.length, @"the table name can not be empty!!!");

    if (columns.count) {
        NSMutableArray<NSString *> *columnNames = [NSMutableArray array];
        NSMutableArray<id> *columnValues = [NSMutableArray array];

        [columns enumerateObjectsUsingBlock:^(HWDBColumn *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {

            if (obj.name.length) {
                [columnNames addObject:obj.name];

                id value = obj.value;

                if (value == nil) {
                    value = [NSNull null];

                } else if (![self.class SQLiteSupportedValue:value]) {
                    if (unsupported) {
                        value = unsupported(obj.name, value);

                        if (![self.class SQLiteSupportedValue:value]) {
                            NSAssert(0, @"unsupported value : < %@ >", value);
                        }

                    } else {
                        NSAssert(0, @"unsupported value : < %@ >", value);
                    }
                }

                [columnValues addObject:value ?: [NSNull null]];
            }
        }];

        return [self executeUpdate:NSString.update(name, columnNames).where(where) values:columnValues error:error];

    } else {
        return YES;
    }
}

- (NSArray<NSDictionary<NSString *, id> *> *)selectRowsWhere:(nullable NSString *)where
                                                     groupBy:(nullable NSArray<NSString *> *)groupColumns
                                                     orderBy:(nullable NSArray<NSString *> *)orderColumns
                                                       limit:(NSInteger)limit
                                                     inTable:(NSString *)name
                                                convertValue:(nullable id (^)(NSString *key, id oldValue))convert
                                                       error:(NSError **)error {
    FMResultSet *result = [self executeQuery:NSString.select(name, @[ @"*" ]).where(where).groupBy(groupColumns).orderBy(orderColumns).limit(limit) values:nil error:error];
    NSMutableArray *array = [NSMutableArray array];
    while (result.next) {
        NSMutableDictionary *dic = [result.resultDictionary mutableCopy];
        if (convert) {
            [dic.allKeys enumerateObjectsUsingBlock:^(id _Nonnull key, NSUInteger idx, BOOL *_Nonnull stop) {
                id newValue = convert(key, dic[key]);
                if (newValue) {
                    dic[key] = newValue;
                } else {
                    [dic removeObjectForKey:key];
                }
            }];
        }
        [array addObject:[dic copy]];
    }
    return [array copy];
}

- (BOOL)deleteRowsWhere:(nullable NSString *)where inTable:(NSString *)name error:(NSError **)error {
    return [self executeUpdate:NSString.delete(name).where(where) values:nil error:error];
}

- (BOOL)columnExists:(NSString *)columnName inTable:(NSString *)name {
    __block BOOL flg = NO;
    [_dbQueue inDatabase:^(FMDatabase *_Nonnull db) {
        flg = [db columnExists:columnName inTableWithName:name];
    }];
    return flg;
}

- (BOOL)addColumns:(HWDBColumnInfo *)columnInfo inTable:(NSString *)name error:(NSError **)error;
{
    return [self executeUpdate:NSString.alterAdd(name, [self.class columnInfos:@[ columnInfo ]]) values:nil error:error];
}

#pragma mark - private

+ (NSArray<NSString *> *)columnInfos:(NSArray<HWDBColumnInfo *> *)columnInfos {
    NSMutableArray *cis = [NSMutableArray array];
    [columnInfos enumerateObjectsUsingBlock:^(HWDBColumnInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [cis addObject:obj.columnInfoSQL];
    }];
    return [cis copy];
}

- (BOOL)executeUpdate:(NSString *)sql values:(nullable NSArray *)values error:(NSError *__autoreleasing *)error {
    __block BOOL flg = NO;
    __block NSError *err = nil;
    [_dbQueue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        NSError *err_t = nil;
        flg = [db executeUpdate:sql values:values error:&err_t];
        err = [err_t copy];
        if (err) {
            *rollback = YES;
        }
    }];

    if (error) {
        *error = err;
    }

    return flg;
}

- (FMResultSet *)executeQuery:(NSString *)sql values:(nullable NSArray *)values error:(NSError *__autoreleasing *)error {
    __block FMResultSet *resultSet = nil;
    __block NSError *err = nil;
    [_dbQueue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        NSError *err_t = nil;
        resultSet = [db executeQuery:sql values:values error:&err_t];
        err = [err_t copy];
        if (err) {
            *rollback = YES;
        }
    }];

    if (error) {
        *error = err;
    }

    return resultSet;
}

@end

@implementation HWDB (ValueSupport)

+ (BOOL)SQLiteSupportedValue:(id)value {
    if (value) {
        if ([value isKindOfClass:[NSDecimalNumber class]] ||
            [value isKindOfClass:[NSNumber class]] ||
            [value isKindOfClass:[NSMutableString class]] ||
            [value isKindOfClass:[NSString class]] ||
            [value isKindOfClass:[NSMutableData class]] ||
            [value isKindOfClass:[NSData class]] ||
            [value isKindOfClass:[NSDate class]] ||
            [value isKindOfClass:[NSNull class]]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

+ (nullable HWSQLiteDataType)SQLiteDataTypeForValue:(id)value {
    if (value) {
        if ([value isKindOfClass:[NSDecimalNumber class]]) {
            return HWSQLiteDataTypeDecimalNumber;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            return HWSQLiteDataTypeNumber;
        } else if ([value isKindOfClass:[NSMutableString class]]) {
            return HWSQLiteDataTypeMutableString;
        } else if ([value isKindOfClass:[NSString class]]) {
            return HWSQLiteDataTypeString;
        } else if ([value isKindOfClass:[NSMutableData class]]) {
            return HWSQLiteDataTypeData;
        } else if ([value isKindOfClass:[NSData class]]) {
            return HWSQLiteDataTypeData;
        } else if ([value isKindOfClass:[NSDate class]]) {
            return HWSQLiteDataTypeDate;
        }
    }
    return nil;
}

+ (nullable HWSQLiteDataType)SQLiteDataTypeForProperty:(HWPropertyInfo *)property {
    if (property) {
        if (property.cls) {
            if ([property.cls isSubclassOfClass:[NSDecimalNumber class]]) {
                return HWSQLiteDataTypeDecimalNumber;
            } else if ([property.cls isSubclassOfClass:[NSNumber class]]) {
                return HWSQLiteDataTypeNumber;
            } else if ([property.cls isSubclassOfClass:[NSMutableString class]]) {
                return HWSQLiteDataTypeMutableString;
            } else if ([property.cls isSubclassOfClass:[NSString class]]) {
                return HWSQLiteDataTypeString;
            } else if ([property.cls isSubclassOfClass:[NSMutableData class]]) {
                return HWSQLiteDataTypeData;
            } else if ([property.cls isSubclassOfClass:[NSData class]]) {
                return HWSQLiteDataTypeData;
            } else if ([property.cls isSubclassOfClass:[NSDate class]]) {
                return HWSQLiteDataTypeDate;
            }
        } else {
            switch (property.dataType) {
                case HWPropertyDataTypeBool:
                    return HWSQLiteDataTypeBool;
                    break;

                case HWPropertyDataTypeChar:
                case HWPropertyDataTypeUChar:
                    return HWSQLiteDataTypeChar;
                    break;

                case HWPropertyDataTypeShort:
                case HWPropertyDataTypeUShort:
                case HWPropertyDataTypeInt:
                case HWPropertyDataTypeUInt:
                    return HWSQLiteDataTypeInt;
                    break;

                case HWPropertyDataTypeFloat:
                case HWPropertyDataTypeDouble:
                    return HWSQLiteDataTypeDouble;
                    break;

                case HWPropertyDataTypeLong:
                case HWPropertyDataTypeULong:
                case HWPropertyDataTypeLongLong:
                case HWPropertyDataTypeULongLong:
                    return HWSQLiteDataTypeLong;
                    break;

                default:
                    break;
            }
        }
    }
    return nil;
}

@end
