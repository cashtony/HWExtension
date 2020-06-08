//
//  NSString+SQL.h
//  HWDatabase
//
//  Created by Wang,Houwen on 2018/11/16.
//  Copyright © 2018 Wang,Houwen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SQL)

#pragma mark -
#pragma mark - creat/insert/delete/select/update

// CREATE TABLE
@property (readonly, class, copy) NSString * (^creatTable)(NSString *table, NSArray<NSString *> *columnInfos);

// DROP
@property (readonly, class, copy) NSString * (^drop)(NSString *table);

// SELECT
@property (readonly, class, copy) NSString * (^select)(NSString *table, NSArray<NSString *> *columns);

// INSERT
@property (readonly, class, copy) NSString * (^insert)(NSString *table, NSArray<NSString *> *columns);

// UPDATE
@property (readonly, class, copy) NSString * (^update)(NSString *table, NSArray<NSString *> *columns);

// DELETE
@property (readonly, class, copy) NSString * (^delete)(NSString *table);

// ALTER ADD
@property (readonly, class, copy) NSString * (^alterAdd)(NSString *table, NSArray<NSString *> *columnInfos);

// ALTER CHANGE
@property (readonly, class, copy) NSString * (^alterChange)(NSString *table, NSString *columnName, NSString *newColumnInfo);

// ALTER MODIFY
@property (readonly, class, copy) NSString * (^alterModify)(NSString *table, NSString *columnName, NSString *dataType);

// ALTER DROP
@property (readonly, class, copy) NSString * (^alterDrop)(NSString *table, NSString *columnName);

#pragma mark - functions

// AVG
@property (readonly, class, copy) NSString * (^avg)(NSString *table, NSString *column);

// MIN
@property (readonly, class, copy) NSString * (^min)(NSString *table, NSString *column);

// MAX
@property (readonly, class, copy) NSString * (^max)(NSString *table, NSString *column);

// SUM
@property (readonly, class, copy) NSString * (^sum)(NSString *table, NSString *column);

// COUNT
@property (readonly, class, copy) NSString * (^count)(NSString *table, NSString *column);

// COUNT DISTINCT
@property (readonly, class, copy) NSString * (^countDistinct)(NSString *table, NSString *column);

// FIRST
@property (readonly, class, copy) NSString * (^first)(NSString *table, NSString *column);

// LAST
@property (readonly, class, copy) NSString * (^last)(NSString *table, NSString *column);

#pragma mark - condition

// DISTINCT
@property (nonatomic, copy, readonly) NSString * (^distinct)(void);

// WHERE
@property (nonatomic, copy, readonly) NSString * (^where)(NSString *where);

// ALIAS
@property (nonatomic, copy, readonly) NSString * (^alias)(NSString *alias);

// AND
@property (nonatomic, copy, readonly) NSString * (^and)(NSString *and);

// OR
@property (nonatomic, copy, readonly) NSString * (^ or)(NSString * or);

// ORDER BY
@property (nonatomic, copy, readonly) NSString * (^orderBy)(NSArray<NSString *> *columns);

// GROUP BY
@property (nonatomic, copy, readonly) NSString * (^groupBy)(NSArray<NSString *> *columns);

// HAVING
@property (nonatomic, copy, readonly) NSString * (^having)(NSString *having);

// LIMIT
@property (nonatomic, copy, readonly) NSString * (^limit)(NSInteger limit);

// LIKE
@property (nonatomic, copy, readonly) NSString * (^like)(NSString *like);

// IN
@property (nonatomic, copy, readonly) NSString * (^in)(NSArray *values);

// BETWEEN
@property (nonatomic, copy, readonly) NSString * (^between)(NSString *low, NSString *high);

// NOT BETWEEN
@property (nonatomic, copy, readonly) NSString * (^notBetween)(NSString *low, NSString *high);

@end

NS_ASSUME_NONNULL_END
