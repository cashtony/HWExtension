//
//  HWFileHelper.m
//  HWExtension
//
//  Created by houwen.wang on 2016/11/4.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWFileHelper.h"

@interface HWFileHelper ()

@property (nonatomic, strong) NSFileManager *fileManager;  //
@property (nonatomic, strong) NSFileHandle *fileHandle;  //

@end

@implementation HWFileHelper

#pragma mark - 获取沙盒目录

// 获取沙盒目录
+ (NSString *)sandboxDirectoryWithType:(HWSandboxDirectoryType)type {
    
    if (type == HWSandboxDirectoryTypeDocument){
        return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    }else if (type == HWSandboxDirectoryTypeLibrary){
        return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    } else if (type == HWSandboxDirectoryTypeHome){
        return NSHomeDirectory();
    } else {
        return NSTemporaryDirectory();
    }
}

#pragma mark - 创建、移动、拷贝、删除

// 创建文件夹
+ (BOOL)creatDirectoryAtPath:(NSString *)path error:(NSError **)error {
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
}

// 创建文件
+ (BOOL)createFileAtPath:(NSString *)path contents:(nullable NSData *)data {
    
    if (path == nil || !path.length)return false;
    
    // 创建父文件夹
    NSString *superDirectory = [path stringByDeletingLastPathComponent];
    BOOL isDirectory ;
    BOOL fileExists = [HWFileHelper fileExistsAtPath:superDirectory isDirectory:&isDirectory];
    if (!(fileExists && isDirectory)){
        [self creatDirectoryAtPath:superDirectory error:nil];
    }
    return [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
}

// 移动文件或文件夹
+ (BOOL)moveItemAtPath:(NSString *)from toPath:(NSString *)to error:(NSError **)error{
    return [[NSFileManager defaultManager] moveItemAtPath:from toPath:to error:error];
}

// 拷贝文件或文件夹
+ (BOOL)copyItemAtPath:(NSString *)from toPath:(NSString *)to error:(NSError **)error{
    return [[NSFileManager defaultManager] copyItemAtPath:from toPath:to error:error];
}

// 删除文件
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

#pragma mark - 可读、可写、可执行、可删除、是否存在

// 文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

// 文件是否存在
+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory{
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:isDirectory];
}

// 文件是否是文件夹
+ (BOOL)isDirectoryAtPath:(NSString *)path {
    BOOL isDirectory = NO;
    BOOL exists = NO;
    exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    return exists && isDirectory;
}

// 文件是否可读
+ (BOOL)isReadableFileAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isReadableFileAtPath:path];
}

// 文件是否可写
+ (BOOL)isWritableFileAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isWritableFileAtPath:path];
}

// 文件是否具有可执行权限
+ (BOOL)isExecutableFileAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isExecutableFileAtPath:path];
}

// 文件是否可删除
+ (BOOL)isDeletableFileAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isDeletableFileAtPath:path];
}

#pragma mark - 内容读取、内容比较、子文件夹路径、子文件路径、文件夹下所有文件名

// 读取文件
+ (NSData *)contentsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] contentsAtPath:path];
}

// 文件夹下的子文件路径和子文件夹路径
+ (NSArray<NSString *> *)subpathsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] subpathsAtPath:path];
}

// 文件夹下的子文件夹路径
+ (NSArray<NSString *> *)subpathsOfDirectoryAtPath:(NSString *)path error:(NSError **)error{
    return [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:error];
}

// 文件夹下所有文件名
+ (NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:error];
}

// 比较文件内容
+ (BOOL)contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2 {
    return [[NSFileManager defaultManager] contentsEqualAtPath:path1 andPath:path2];
}

#pragma mark - 文件属性、大小、类型、创建时间

// 文件属性字典
+ (nullable NSDictionary<NSFileAttributeKey, id> *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error {
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
}

// 文件大小
+ (unsigned long long)fileSizeOfItemAtPath:(NSString *)path error:(NSError **)error {
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:error] fileSize];
}

// 文件类型
+ (nullable NSString *)fileTypeOfItemAtPath:(NSString *)path error:(NSError **)error {
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:error] fileType];
}

// 文件创建时间
+ (nullable NSDate *)fileCreationDateOfItemAtPath:(NSString *)path error:(NSError **)error {
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:error] fileCreationDate];
}

// 文件拥有者name
+ (nullable NSString *)fileOwnerAccountNameOfItemAtPath:(NSString *)path error:(NSError **)error {
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:error] fileOwnerAccountName];
}

// 文件拥有者ID
+ (nullable NSNumber *)fileOwnerAccountIDOfItemAtPath:(NSString *)path error:(NSError **)error {
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:error] fileOwnerAccountID];
}

@end
