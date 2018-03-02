//
//  HWFileHelper.h
//  HWExtension
//
//  Created by houwen.wang on 2016/11/4.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 沙盒目录
typedef NS_ENUM(NSUInteger, HWSandboxDirectoryType){
    HWSandboxDirectoryTypeTemporary,
    HWSandboxDirectoryTypeDocument,
    HWSandboxDirectoryTypeLibrary,
    HWSandboxDirectoryTypeHome,
};

@interface HWFileHelper : NSObject

#pragma mark - 获取沙盒目录

// 获取沙盒目录
+ (NSString *)sandboxDirectoryWithType:(HWSandboxDirectoryType)type;

#pragma mark - 创建、移动、拷贝、删除

// 创建文件夹
+ (BOOL)creatDirectoryAtPath:(NSString *)path error:(NSError **)error;

// 创建文件
+ (BOOL)createFileAtPath:(NSString *)path contents:(nullable NSData *)data;

// 移动文件或文件夹
+ (BOOL)moveItemAtPath:(NSString *)from toPath:(NSString *)to error:(NSError **)error;

// 拷贝文件或文件夹
+ (BOOL)copyItemAtPath:(NSString *)from toPath:(NSString *)to error:(NSError **)error;

// 删除文件
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 可读、可写、可执行、可删除、是否存在

// 文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)path;

// 文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory;

// 文件是否是文件夹
+ (BOOL)isDirectoryAtPath:(NSString *)path;

// 文件是否可读
+ (BOOL)isReadableFileAtPath:(NSString *)path;

// 文件是否可写
+ (BOOL)isWritableFileAtPath:(NSString *)path;

// 文件是否具有可执行权限
+ (BOOL)isExecutableFileAtPath:(NSString *)path;

// 文件是否可删除
+ (BOOL)isDeletableFileAtPath:(NSString *)path;

#pragma mark - 内容读取、内容比较、子文件夹路径、子文件路径、文件夹下所有文件名

// 读取文件
+ (NSData *)contentsAtPath:(NSString *)path;

// 文件夹下的子文件路径和子文件夹路径
+ (NSArray<NSString *> *)subpathsAtPath:(NSString *)path;

// 文件夹下的子文件夹路径
+ (NSArray<NSString *> *)subpathsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

// 文件夹下所有文件名
+ (NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

// 比较文件内容
+ (BOOL)contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2;

#pragma mark - 文件属性、大小、类型、创建时间、文件拥有者name、文件拥有者ID

// 文件属性字典
+ (nullable NSDictionary<NSFileAttributeKey, id> *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;

// 文件大小
+ (unsigned long long)fileSizeOfItemAtPath:(NSString *)path error:(NSError **)error;

// 文件类型
+ (nullable NSString *)fileTypeOfItemAtPath:(NSString *)path error:(NSError **)error;

// 文件创建时间
+ (nullable NSDate *)fileCreationDateOfItemAtPath:(NSString *)path error:(NSError **)error;

// 文件拥有者name
+ (nullable NSString *)fileOwnerAccountNameOfItemAtPath:(NSString *)path error:(NSError **)error;

// 文件拥有者ID
+ (nullable NSNumber *)fileOwnerAccountIDOfItemAtPath:(NSString *)path error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
