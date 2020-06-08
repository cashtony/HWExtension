//
//  NSString+SQL.m
//  HWDatabase
//
//  Created by Wang,Houwen on 2018/11/16.
//  Copyright © 2018 Wang,Houwen. All rights reserved.
//

#import "NSString+SQL.h"

@implementation NSString (SQL)

#pragma mark -
#pragma mark - creat/insert/delete/select/update

// CREATE TABLE
+ (NSString *_Nonnull (^)(NSString *_Nonnull, NSArray<NSString *> *_Nonnull))creatTable {
    return ^NSString *(NSString *table, NSArray<NSString *> *columnInfos) {
        return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", table, [columnInfos componentsJoinedByString:@", "]];
    };
}

// DROP
+ (NSString *_Nonnull (^)(NSString *_Nonnull))drop {
    return ^NSString *(NSString *table) {
        return [NSString stringWithFormat:@"DROP TABLE %@", table];
    };
}

// SELECT
+ (NSString * (^)(NSString *, NSArray<NSString *> *))select {
    return ^NSString *(NSString *table, NSArray<NSString *> *columns) {
        NSString *columnsStr = [columns componentsJoinedByString:@", "];
        NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@", columnsStr.length ? columnsStr : @"*", table];
        return sql;
    };
}

// INSERT
+ (NSString *_Nonnull (^)(NSString *_Nonnull, NSArray<NSString *> *_Nonnull))insert {
    return ^NSString *(NSString *table, NSArray<NSString *> *columns) {
        if (!columns.count)
            return @"";

        NSString *columnsStr = [columns componentsJoinedByString:@", "];

        NSMutableArray *values = [NSMutableArray array];
        [columns enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [values addObject:@"?"];
        }];

        NSString *valuesStr = [values componentsJoinedByString:@", "];

        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", table, columnsStr, valuesStr];

        return sql;
    };
}

// UPDATE
+ (NSString *_Nonnull (^)(NSString *_Nonnull, NSArray<NSString *> *_Nonnull))update {
    return ^NSString *(NSString *table, NSArray<NSString *> *columns) {
        if (!columns.count)
            return @"";

        NSMutableString *setKeyValue = [NSMutableString string];
        [columns enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [setKeyValue appendFormat:@"%@ = ?,", obj];
        }];

        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@", table, [setKeyValue substringToIndex:setKeyValue.length - 1]];
        return sql;
    };
}

// DELETE
+ (NSString * (^)(NSString *)) delete {
    return ^NSString *(NSString *table) {
        return [NSString stringWithFormat:@"DELETE FROM %@", table];
    };
}

// ALTER ADD
+ (NSString *_Nonnull (^)(NSString *_Nonnull, NSArray<NSString *> *_Nonnull))alterAdd {
    return ^NSString *(NSString *table, NSArray<NSString *> *columnInfos) {
        return [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@", table, [columnInfos componentsJoinedByString:@", "]];
    };
}

// ALTER CHANGE
+ (NSString *_Nonnull (^)(NSString *_Nonnull, NSString *_Nonnull, NSString *_Nonnull))alterChange {
    return ^NSString *(NSString *table, NSString *columnName, NSString *newColumnInfo) {
        return [NSString stringWithFormat:@"ALTER TABLE %@ CHANGE %@ %@", table, columnName, newColumnInfo];
    };
}

// ALTER MODIFY
+ (NSString *_Nonnull (^)(NSString *_Nonnull, NSString *_Nonnull, NSString *_Nonnull))alterModify {
    return ^NSString *(NSString *table, NSString *columnName, NSString *dataType) {
        return [NSString stringWithFormat:@"ALTER TABLE %@ MODIFY %@ %@", table, columnName, dataType];
    };
}

// ALTER DROP
+ (NSString *_Nonnull (^)(NSString *_Nonnull, NSString *_Nonnull))alterDrop {
    return ^NSString *(NSString *table, NSString *columnName) {
        return [NSString stringWithFormat:@"ALTER TABLE %@ DROP %@", table, columnName];
    };
}

#pragma mark - functions

// AVG
+ (NSString * (^)(NSString *, NSString *))avg {
    return ^NSString *(NSString *table, NSString *column) {
        return [NSString stringWithFormat:@"SELECT AVG(%@) FROM %@", column, table];
    };
}

// MIN
+ (NSString * (^)(NSString *, NSString *))min {
    return ^NSString *(NSString *table, NSString *column) {
        return [NSString stringWithFormat:@"SELECT MIN(%@) FROM %@", column, table];
    };
}

// MAX
+ (NSString * (^)(NSString *, NSString *))max {
    return ^NSString *(NSString *table, NSString *column) {
        return [NSString stringWithFormat:@"SELECT MAX(%@) FROM %@", column, table];
    };
}

// SUM
+ (NSString * (^)(NSString *, NSString *))sum {
    return ^NSString *(NSString *table, NSString *column) {
        return [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@", column, table];
    };
}

// COUNT
+ (NSString * (^)(NSString *, NSString *))count {
    return ^NSString *(NSString *table, NSString *column) {
        return [NSString stringWithFormat:@"SELECT COUNT(%@) FROM %@", column, table];
    };
}

// COUNT DISTINCT
+ (NSString * (^)(NSString *, NSString *))countDistinct {
    return ^NSString *(NSString *table, NSString *column) {
        return [NSString stringWithFormat:@"SELECT COUNT(DISTINCT %@) FROM %@", column, table];
    };
}

// FIRST
+ (NSString * (^)(NSString *, NSString *))first {
    return ^NSString *(NSString *table, NSString *column) {
        return [NSString stringWithFormat:@"SELECT FIRST(%@) FROM %@", column, table];
    };
}

// LAST
+ (NSString * (^)(NSString *, NSString *))last {
    return ^NSString *(NSString *table, NSString *column) {
        return [NSString stringWithFormat:@"SELECT LAST(%@) FROM %@", column, table];
    };
}

#pragma mark - condition

// DISTINCT
- (NSString * (^)(void))distinct {
    return ^NSString *() {
        if ([self.uppercaseString hasPrefix:@"SELECT "]) {
            return [self stringByReplacingOccurrencesOfString:@"SELECT " withString:@"SELECT DISTINCT "];
        }
        return self;
    };
}

// WHERE
- (NSString * (^)(NSString *))where {
    return ^NSString *(NSString *where) {
        return where.length ? [self stringByAppendingFormat:@" WHERE %@", where] : self;
    };
}

// ALIAS
- (NSString * (^)(NSString *))alias {
    return ^NSString *(NSString *alias) {
        return alias.length ? [self stringByAppendingFormat:@" AS %@", alias] : self;
    };
}

// AND
- (NSString * (^)(NSString *)) and {
    return ^NSString *(NSString *and) {
        return and.length ? [self stringByAppendingFormat:@" AND %@", and] : self;
    };
}

// OR
- (NSString * (^)(NSString *)) or {
    return ^NSString *(NSString * or) {
        return or.length ? [self stringByAppendingFormat:@" OR %@", or ] : self;
    };
}

// ORDER BY
- (NSString * (^)(NSArray<NSString *> *))orderBy {
    return ^NSString *(NSArray<NSString *> *columns) {
        return columns.count ? [self stringByAppendingFormat:@" ORDER BY %@", [columns componentsJoinedByString:@", "]] : self;
    };
}

// GROUP BY
- (NSString * (^)(NSArray<NSString *> *))groupBy {
    return ^NSString *(NSArray<NSString *> *columns) {
        return columns.count ? [self stringByAppendingFormat:@" GROUP BY %@", [columns componentsJoinedByString:@", "]] : self;
    };
}

// HAVING
- (NSString * (^)(NSString *))having {
    return ^NSString *(NSString *having) {
        return having.length ? [self stringByAppendingFormat:@" HAVING %@", having] : self;
    };
}

// LIMIT
- (NSString * (^)(NSInteger))limit {
    return ^NSString *(NSInteger limit) {
        return [self stringByAppendingFormat:@" LIMIT %@", @(limit)];
    };
}

// LIKE
- (NSString * (^)(NSString *))like {
    return ^NSString *(NSString *like) {
        return like.length ? [self stringByAppendingFormat:@" LIKE %@", like] : self;
    };
}

// IN
- (NSString * (^)(NSArray *))in {
    return ^NSString *(NSArray *values) {
        if (!values.count)
            return self;
        return [self stringByAppendingFormat:@" IN (%@)", [values componentsJoinedByString:@", "]];
    };
}

// BETWEEN
- (NSString * (^)(NSString *, NSString *))between {
    return ^NSString *(NSString *low, NSString *high) {
        if (!low.length && !high.length)
            return self;
        return [self stringByAppendingFormat:@" BETWEEN %@ AND %@", low, high];
    };
}

// NOT BETWEEN
- (NSString * (^)(NSString *, NSString *))notBetween {
    return ^NSString *(NSString *low, NSString *high) {
        if (!low.length && !high.length)
            return self;
        return [self stringByAppendingFormat:@" NOT BETWEEN %@ AND %@", low, high];
    };
}

@end
