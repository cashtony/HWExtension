//
//  HWStuckMonitor.m
//  HWExtension_Example
//
//  Created by Wang,Houwen on 2020/1/15.
//  Copyright © 2020 wanghouwen. All rights reserved.
//

#import "HWStuckMonitor.h"
#import "HWRunLoopObserver.h"
#import "BSBacktraceLogger.h"
#import <mach/mach.h>
#import <pthread/pthread.h>

static mach_port_t main_thread_id;
static NSThread *monitorThread;

@implementation HWStuckMonitor

+ (void)load {
    main_thread_id = mach_thread_self();
    monitorThread = [[NSThread alloc] initWithTarget:self selector:@selector(stuckMoniting) object:nil];
    monitorThread.name = @"StuckMonitor";
    [monitorThread start];

    //    static CFAbsoluteTime entry = -1.f;
    //    static CFAbsoluteTime beforeWaiting = -1.f;
    //    static CFAbsoluteTime afterWaiting = -1.f;
    //    NSDictionary *map = @{ @(kCFRunLoopEntry) : @"Entry",
    //                           @(kCFRunLoopBeforeTimers) : @"BeforeTimers",
    //                           @(kCFRunLoopBeforeSources) : @"BeforeSources",
    //                           @(kCFRunLoopBeforeWaiting) : @"BeforeWaiting",
    //                           @(kCFRunLoopAfterWaiting) : @"AfterWaiting",
    //                           @(kCFRunLoopExit) : @"Exit" };
    //    HWRunLoopObserver *enterObs = [HWRunLoopObserver observerWithActivity:kCFRunLoopAllActivities
    //                                                                  repeats:YES
    //                                                                 callBack:^(HWRunLoopObserver *observer,
    //                                                                            CFRunLoopActivity activity) {
    //                                                                     printf("=========%s\n", [map[@(activity)] UTF8String]);
    //                                                                     if (activity == kCFRunLoopEntry) {
    //                                                                         entry = CFAbsoluteTimeGetCurrent();
    //                                                                     } else if (activity == kCFRunLoopBeforeWaiting) {
    //                                                                         CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    //                                                                         if (beforeWaiting < 0) {
    //                                                                             printf("=========启动耗时：%f\n", time - entry);
    //                                                                         } else {
    //                                                                             printf("=========loop耗时：%f\n", time - afterWaiting);
    //                                                                         }
    //                                                                         beforeWaiting = time;
    //                                                                         BSLOG_ALL
    //                                                                     } else if (activity == kCFRunLoopAfterWaiting) {
    //                                                                         afterWaiting = CFAbsoluteTimeGetCurrent();
    ////                                                                         printf("=========休眠了：%f\n", afterWaiting - beforeWaiting);
    //                                                                     }
    //                                                                 }];
    //    [enterObs observerRunLoop:[NSRunLoop mainRunLoop]
    //                     forModes:@[ UITrackingRunLoopMode,
    //                                 NSRunLoopCommonModes,
    //                                 NSDefaultRunLoopMode ]];
}

+ (void)stuckMoniting {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(dumpThreads) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

struct __thread_info {
    thread_basic_info_t info;
    integer_t cpu_usage;
    integer_t run_state;
    char *name;
    BOOL is_main;
};

+ (void)dumpThreads {
    thread_act_array_t threads;
    mach_msg_type_number_t threadCnt = 0;
    struct __thread_info infos[128] = {NULL};
    if (task_threads(mach_task_self(), &threads, &threadCnt) == KERN_SUCCESS) {
        for (int idx = 0; idx < threadCnt; idx++) {
            thread_info_data_t thinfo;
            mach_msg_type_number_t thread_info_outCnt = THREAD_INFO_MAX;
            thread_t th = threads[idx];
            if (thread_info(th, THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_outCnt) == KERN_SUCCESS) {
                thread_basic_info_t basic_info_t = (thread_basic_info_t)thinfo;
                if (!(basic_info_t->flags & TH_FLAGS_IDLE)) {
                    double cpu_usage = basic_info_t->cpu_usage / (double)TH_USAGE_SCALE;
                    char name[256] = {0};
                    pthread_t pt = pthread_from_mach_thread_np(th);
                    pthread_getname_np(pt, name, sizeof name);
                    struct __thread_info info = {basic_info_t, cpu_usage, basic_info_t->run_state, name, threads[idx] == main_thread_id};
                    if (info.is_main && name[0] == '\0') {
                        memcpy(info.name, "mainThread", 10);
                    }
                    infos[idx] = info;
                    printf("=========cpu：[ %f ], name：[ %s ]\n", cpu_usage, name);
                }
            }
        }
    }
}

@end
