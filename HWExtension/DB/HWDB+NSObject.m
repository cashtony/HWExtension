//
//  HWDB+NSObject.m
//  HWDatabase
//
//  Created by Wang,Houwen on 2018/11/18.
//  Copyright © 2018 Wang,Houwen. All rights reserved.
//

#import "HWDB+NSObject.h"

@implementation HWDB (NSObject)

- (BOOL)creatTable:(NSString *)name
                 forClass:(Class)cls
           ignoreProperty:(nullable BOOL (^)(NSString *property))ignore
         columnConstraint:(nullable NSArray<HWColumnConstraint> * (^)(NSString *property))constraint
    unsupportedProperties:(nullable HWSQLiteDataType (^)(NSString *property))unsupported
                    error:(NSError **)error {
    NSAssert(name.length, @"the table name can not be empty!!!");

    NSArray<NSString *> *nsObjectProperties = propertyNameList([NSObject class]);
    NSMutableArray *columns = [NSMutableArray array];

    NSString *ignorePropertiesPath = [[self.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@".ignoreProperties"];
    NSMutableDictionary<NSString *, NSMutableArray *> *ignorePropertiesMap = [NSMutableDictionary dictionaryWithContentsOfFile:ignorePropertiesPath];
    if (!ignorePropertiesMap) {
        ignorePropertiesMap = [NSMutableDictionary dictionary];
    }
    NSMutableArray *ignoreProperties = [NSMutableArray array];

    [[cls propertyList] enumerateObjectsUsingBlock:^(HWPropertyInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {

        if (![nsObjectProperties containsObject:obj.name]) {
            BOOL shouldIgnore = ignore ? ignore(obj.name) : NO;

            if (!shouldIgnore) {
                HWSQLiteDataType dataType = [self.class SQLiteDataTypeForProperty:obj];

                if (!dataType.length && unsupported) {
                    dataType = unsupported(obj.name);
                    NSAssert(dataType.length, @"unsupported property : %@!!!", obj.name);
                }

                HWDBColumnInfo *info = [HWDBColumnInfo columnInfoWithName:obj.name dataType:dataType constraint:(constraint ? constraint(obj.name) : nil)];
                [columns addObject:info];
            } else {
                [ignoreProperties addObject:obj.name];
            }
        }
    }];

    if (ignoreProperties.count) {
        ignorePropertiesMap[name] = ignoreProperties;
        [ignorePropertiesMap writeToFile:ignorePropertiesPath atomically:YES];
    }

    return [self creatTable:name columns:columns error:error];
}

- (BOOL)insertObject:(NSObject *)object
              inTable:(NSString *)name
    unsupportedValues:(nullable id (^)(NSString *key, id value))unsupported
                error:(NSError **)error {
    NSArray<NSString *> *nsObjectProperties = propertyNameList([NSObject class]);
    NSMutableArray *columns = [NSMutableArray array];

    NSArray<NSString *> *ignoreProperties = [self ignorePropertiesForTable:name];

    [propertyList(object.class) enumerateObjectsUsingBlock:^(HWPropertyInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (![nsObjectProperties containsObject:obj.name] && ![ignoreProperties containsObject:obj.name]) {
            HWDBColumn *info = [HWDBColumn columnWithName:obj.name value:[object valueForKey:obj.name]];
            [columns addObject:info];
        }
    }];

    return [self insertRowWithColumns:columns inTable:name unsupportedValues:unsupported error:error];
}

- (BOOL)updateRowsWithObject:(NSObject *)object
                     inTable:(NSString *)name
              ignoreProperty:(nullable BOOL (^)(NSString *property))ignore
           unsupportedValues:(nullable id (^)(NSString *key, id value))unsupported
                       where:(nullable NSString *)where
                       error:(NSError **)error {
    NSArray<NSString *> *nsObjectProperties = propertyNameList([NSObject class]);
    NSMutableArray *columns = [NSMutableArray array];

    [propertyList(object.class) enumerateObjectsUsingBlock:^(HWPropertyInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (![nsObjectProperties containsObject:obj.name]) {
            BOOL shouldIgnore = NO;

            if (ignore) {
                shouldIgnore = ignore(obj.name);
            }

            if (!shouldIgnore) {
                HWDBColumn *info = [HWDBColumn columnWithName:obj.name value:[object valueForKey:obj.name]];
                [columns addObject:info];
            }
        }
    }];

    return [self updateRowsWithColumns:columns inTable:name unsupportedValues:unsupported where:where error:error];
}

- (NSArray *)selectObjectsWhere:(nullable NSString *)where
                        groupBy:(nullable NSArray<NSString *> *)groupColumns
                        orderBy:(nullable NSArray<NSString *> *)orderColumns
                          limit:(NSInteger)limit
                        inTable:(NSString *)name
                    objectClass:(Class)cls
                  convertValues:(nullable id (^)(NSString *key, id oldValue))convert
                          error:(NSError **)error {
    NSArray<NSDictionary *> *result = [self selectRowsWhere:where groupBy:groupColumns orderBy:orderColumns limit:limit inTable:name convertValue:convert error:error];
    NSMutableArray *array = [NSMutableArray array];

    [result enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSObject *obj_t = [[cls alloc] init];
        [obj_t setValuesForKeysWithDictionary:obj];
        [array addObject:obj_t];
    }];
    return [array copy];
}

#pragma mark - private

- (NSArray<NSString *> *)ignorePropertiesForTable:(NSString *)tableName {
    if (!tableName) {
        return nil;
    }
    NSString *ignorePropertiesPath = [[self.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@".ignoreProperties"];
    return [NSMutableDictionary dictionaryWithContentsOfFile:ignorePropertiesPath][tableName];
}

@end
