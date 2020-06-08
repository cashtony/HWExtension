//
//  HWDB+NSObject.h
//  HWDatabase
//
//  Created by Wang,Houwen on 2018/11/18.
//  Copyright © 2018 Wang,Houwen. All rights reserved.
//

#import "HWDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface HWDB (NSObject)

- (BOOL)creatTable:(NSString *)name
                 forClass:(Class)cls
           ignoreProperty:(nullable BOOL (^)(NSString *property))ignore
         columnConstraint:(nullable NSArray<HWColumnConstraint> * (^)(NSString *property))constraint
    unsupportedProperties:(nullable HWSQLiteDataType (^)(NSString *property))unsupported
                    error:(NSError **)error;

- (BOOL)insertObject:(NSObject *)object
              inTable:(NSString *)name
    unsupportedValues:(nullable id (^)(NSString *key, id value))unsupported
                error:(NSError **)error;

- (BOOL)updateRowsWithObject:(NSObject *)object
                     inTable:(NSString *)name
              ignoreProperty:(nullable BOOL (^)(NSString *property))ignore
           unsupportedValues:(nullable id (^)(NSString *key, id value))unsupported
                       where:(nullable NSString *)where
                       error:(NSError **)error;

- (NSArray *)selectObjectsWhere:(nullable NSString *)where
                        groupBy:(nullable NSArray<NSString *> *)groupColumns
                        orderBy:(nullable NSArray<NSString *> *)orderColumns
                          limit:(NSInteger)limit
                        inTable:(NSString *)name
                    objectClass:(Class)cls
                  convertValues:(nullable id (^)(NSString *key, id oldValue))convert
                          error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
