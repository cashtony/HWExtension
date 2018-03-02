//
//  HWDirectoryWatcher.h
//  HWExtension
//
//  Created by houwen.wang on 2016/11/24.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//
//  文件监控

#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>
#import <Foundation/Foundation.h>

@class HWDirectoryWatcher;

@protocol HWDirectoryWatcherDelegate <NSObject>

- (void)directoryDidChange:(HWDirectoryWatcher *)folderWatcher;

@end

@interface HWDirectoryWatcher : NSObject

@property (nonatomic, weak) id <HWDirectoryWatcherDelegate> delegate;

+ (HWDirectoryWatcher *)watchFolderWithPath:(NSString *)watchPath delegate:(id<HWDirectoryWatcherDelegate>)watchDelegate;
- (void)invalidate;

@end
