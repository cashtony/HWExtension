//
//  NSString+Category.h
//  HWExtension
//
//  Created by houwen.wang on 2016/11/4.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Category)

+ (BOOL)isEmpty:(NSString *)str;                                // nil or length == 0 return YES
- (BOOL)containsString:(NSString *)str;                         // 是否包含
- (NSString *)stringByAdd:(NSString *)str;                      // 追加
- (NSComparisonResult)compareNumber:(NSNumber *)otherNumber;    // 和 NSNumber 比较

// 空字符串处理
+ (NSString *)handlerString:(NSString *)str emptyReplacing:(NSString *)replacing;

// 替换一组string
- (NSString *)stringByReplacingOccurrencesOfStrings:(NSArray <NSString *>*)targets withSting:(NSString *)string;

@end

@interface NSString (Filter)

// 遍历字符串中所有数字字符(连续的数字将连接成一个数字) e.g. @"123ab c 45 6de f" return @[@"123",@"45",@"6"]
@property (nonatomic, strong, readonly) NSArray <NSString *>*numberStrings;

// 遍历字符串中所有 'a'-'z' ,'A'-'Z'的字符串 e.g. @"123ab c 45 6de f" return @[@"ab",@"c",@"de",@"f"]
@property (nonatomic, strong, readonly) NSArray <NSString *>*alphabetStrings;

@property (nonatomic, strong, readonly) NSArray <NSString *>*uppercaseAlphabetStrings;  // 大写字符串
@property (nonatomic, strong, readonly) NSArray <NSString *>*lowercaseAlphabetStrings;  // 小写字符串

// 按字符集遍历字符串
- (NSArray <NSString *>*)filterCharactersFromSet:(NSCharacterSet *)set;

// 使用正则表达式匹配字符串
- (NSArray <NSString *>*)matcheStringsWithRegexString:(NSString *)regexStr;

// 使用正则表达式匹配字符串
- (NSArray <NSString *>*)matcheStringsWithRegexString:(NSString *)regexStr inRange:(NSRange)range;

// 使用正则表达式匹配字符串
- (NSArray <NSTextCheckingResult *>*)matchesWithRegularExpressionPattern:(NSString *)pattern;

// 使用正则表达式匹配字符串
- (NSArray <NSTextCheckingResult *>*)matchesWithRegularExpressionPattern:(NSString *)pattern range:(NSRange)range;

@end

@interface NSString (NSPredicate)

// Email
-(BOOL)isValidateEmail;

// URL
-(BOOL)isValidateURL;

// 验证身份证号（15位或18位数字）
-(BOOL)isValidateIdentificationNumber;

- (BOOL)canMatcheWithRegex:(NSString *)regex;

@end

@interface NSString (Unicode)

- (NSString *)stringByReplacingUnicodeString; // 中文显示

@end

@interface NSString (NSDate)

// timeZone is GMT+0800
- (NSDate *)dateWithFormat:(NSString *)format ;
- (NSDate *)dateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone;

@end

@interface NSString (NSNumberFormatter)

- (NSString *)numberStringWithPositiveFormat:(NSString *)positiveFormat negativeFormat:(NSString *)negativeFormat;

// 小数位四舍五入, scale : 小数点后有效位数, complete : 是否需要补齐位数
- (NSString *)roundedNumberStringWithScale:(short)scale complete:(BOOL)complete;

// 小数位处理, scale : 小数点后有效位数, roundingMode : 最后一位取舍策略, complete : 是否需要补齐位数
/*
 NSRoundPlain,  四舍五入
 NSRoundDown,   只舍不入
 NSRoundUp,     只入不舍
 NSRoundBankers 四舍六入, 中间值时, 取最近的,保持保留最后一位为偶数
 */
- (NSString *)roundedNumberStringWithScale:(short)scale roundingMode:(NSRoundingMode)roundingMode complete:(BOOL)complete;

@end

// 使用 * 格式化
@interface NSString (SecureFormatter)

@property (nonatomic, copy, readonly) NSString *allSecureFormatterString;    //
@property (nonatomic, copy, readonly) NSString *secureFormatterUserName;     //
@property (nonatomic, copy, readonly) NSString *secureFormatterPhoneNumber;  //

@end

// 富文本
@interface NSString (AttributedString)

- (NSMutableAttributedString *)attributedStringWithColor:(UIColor *)color;
- (NSMutableAttributedString *)attributedStringWithFont:(UIFont *)font;
- (NSMutableAttributedString *)attributedStringWithColor:(UIColor *)color font:(UIFont *)font;
- (NSMutableAttributedString *)attributedStringWithColor:(UIColor *)color range:(NSRange)range;
- (NSMutableAttributedString *)attributedStringWithFont:(UIFont *)font range:(NSRange)range;
- (NSMutableAttributedString *)attributedStringWithColor:(UIColor *)color font:(UIFont *)font range:(NSRange)range;

- (NSAttributedString *)attributedFromHTML;

@end

@interface NSString (URL)

- (NSString *)hw_stringByRemovingPercentEncoding ;  // 移除 PercentEncoding
- (NSString *)hw_stringByAddingPercentEncoding;     // 增加 PercentEncoding

-(NSURL *)hw_URL; // 先移除PercentEncoding,再添加PercentEncoding

@end

typedef NSString *HWDBColumnInfo;
typedef NSString *HWSQLiteDataType NS_EXTENSIBLE_STRING_ENUM;

#define HWDBColumnInfo(columnName, dataType) ((HWDBColumnInfo)[NSString stringWithFormat:@"%@ %@", columnName, dataType])

/*
 *  SQLite data types
 */
extern HWSQLiteDataType const HWSQLiteDataTypeBool;             // BOOL
extern HWSQLiteDataType const HWSQLiteDataTypeInt;              // int
extern HWSQLiteDataType const HWSQLiteDataTypeInteger;          // NSInteger
extern HWSQLiteDataType const HWSQLiteDataTypeLong;             // long

extern HWSQLiteDataType const HWSQLiteDataTypeDouble;           // double
extern HWSQLiteDataType const HWSQLiteDataTypeReal;             // double

extern HWSQLiteDataType const HWSQLiteDataTypeNumber;           // NSNumber
extern HWSQLiteDataType const HWSQLiteDataTypeDecimalNumber;    // NSDecimalNumber

extern HWSQLiteDataType const HWSQLiteDataTypeChar;             // char
extern HWSQLiteDataType const HWSQLiteDataTypeString;           // NSString
extern HWSQLiteDataType const HWSQLiteDataTypeText;             // NSString
extern HWSQLiteDataType const HWSQLiteDataTypeMutableString;    // NSMutableString

extern HWSQLiteDataType const HWSQLiteDataTypeData;             // NSData

extern HWSQLiteDataType const HWSQLiteDataTypeDate;             // NSDate e.g.YYYY-MM-dd
extern HWSQLiteDataType const HWSQLiteDataTypeTime;             // NSDate e.g.HH:mm:ss
extern HWSQLiteDataType const HWSQLiteDataTypeDateTime;         // NSDate e.g.YYYY-MM-dd HH:mm:ss

@interface NSString (SQLite)

#pragma mark -
#pragma mark - creat/insert/delete/select/update

// CREATE TABLE
@property (readonly, class, copy) NSString *(^creatTable)(NSString *table, NSArray <HWDBColumnInfo>*columnInfos);

// SELECT
@property (readonly, class, copy) NSString *(^select)(NSString *table, NSArray <NSString *>*columns);

// INSERT
@property (readonly, class, copy) NSString *(^insert)(NSString *table, NSDictionary <NSString *, id>*keyValues);

// UPDATE
@property (readonly, class, copy) NSString *(^update)(NSString *table, NSDictionary <NSString *, id>*keyValues);

// DELETE
@property (readonly, class, copy) NSString *(^delete)(NSString *table);


#pragma mark - functions

// AVG
@property (readonly, class, copy) NSString *(^avg)(NSString *table, NSString *column);

// MIN
@property (readonly, class, copy) NSString *(^min)(NSString *table, NSString *column);

// MAX
@property (readonly, class, copy) NSString *(^max)(NSString *table, NSString *column);

// SUM
@property (readonly, class, copy) NSString *(^sum)(NSString *table, NSString *column);

// COUNT
@property (readonly, class, copy) NSString *(^count)(NSString *table, NSString *column);

// COUNT DISTINCT
@property (readonly, class, copy) NSString *(^countDistinct)(NSString *table, NSString *column);

// FIRST
@property (readonly, class, copy) NSString *(^first)(NSString *table, NSString *column);

// LAST
@property (readonly, class, copy) NSString *(^last)(NSString *table, NSString *column);

#pragma mark - condition

// DISTINCT
@property (nonatomic, copy, readonly) NSString *(^distinct)(void);

// WHERE
@property (nonatomic, copy, readonly) NSString *(^where)(NSString *where);

// ALIAS
@property (nonatomic, copy, readonly) NSString *(^alias)(NSString *alias);

// AND
@property (nonatomic, copy, readonly) NSString *(^and)(NSString *and);

// OR
@property (nonatomic, copy, readonly) NSString *(^or)(NSString *or);

// ORDER BY
@property (nonatomic, copy, readonly) NSString *(^orderBy)(NSString *orderBy);

// GROUP BY
@property (nonatomic, copy, readonly) NSString *(^groupBy)(NSString *groupBy);

// HAVING
@property (nonatomic, copy, readonly) NSString *(^having)(NSString *having);

// LIMIT
@property (nonatomic, copy, readonly) NSString *(^limit)(NSUInteger limit);

// LIKE
@property (nonatomic, copy, readonly) NSString *(^like)(NSString *like);

// IN
@property (nonatomic, copy, readonly) NSString *(^in)(NSArray *values);

// BETWEEN
@property (nonatomic, copy, readonly) NSString *(^between)(NSString *low, NSString *high);

// NOT BETWEEN
@property (nonatomic, copy, readonly) NSString *(^notBetween)(NSString *low, NSString *high);

@end
