//
//  HWDefines.h
//  HWExtension
//
//  Created by houwen.wang on 2016/11/29.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#ifndef HWDefines_h
#define HWDefines_h

#import "NSObject+Category.h"

#define kScreenBounds  ([UIScreen mainScreen].bounds)
#define kScreenSize    (kScreenBounds.size)
#define kScreenWidth   (kScreenSize.width)
#define kScreenHeight  (kScreenSize.height)

/*
 
 BuildMachineOSBuild = 17C88;
 CFBundleDevelopmentRegion = en;
 CFBundleExecutable = HWExtensionExample;
 CFBundleIdentifier = "wanghouwen.HWExtensionExample";
 CFBundleInfoDictionaryVersion = "6.0";
 CFBundleName = HWExtensionExample;
 CFBundleNumericVersion = 0;
 CFBundlePackageType = APPL;
 CFBundleShortVersionString = "1.0";
 CFBundleSupportedPlatforms =     (
 iPhoneSimulator
 );
 CFBundleVersion = 112;
 DTCompiler = "com.apple.compilers.llvm.clang.1_0";
 DTPlatformBuild = "";
 DTPlatformName = iphonesimulator;
 DTPlatformVersion = "11.2";
 DTSDKBuild = 15C107;
 DTSDKName = "iphonesimulator11.2";
 DTXcode = 0920;
 DTXcodeBuild = 9C40b;
 LSRequiresIPhoneOS = 1;
 MinimumOSVersion = "8.0";

 */

/* Bundle Info */
#define kMainBundleInfo                 ([[NSBundle mainBundle] infoDictionary])
#define kMainBundleIdentifier           (kMainBundleInfo[@"CFBundleIdentifier"])
#define kMainBundleName                 (kMainBundleInfo[@"CFBundleName"])
#define kMainBundleShortVersionString   (kMainBundleInfo[@"CFBundleShortVersionString"])
#define kMainBundleVersion              (kMainBundleInfo[@"CFBundleVersion"])

// 调用block块
#define executeBlock(b, ...) if (b) { b(__VA_ARGS__); }

// 调用block块
#define executeReturnValueBlock(b, nilReturnValue, ...) if (b) { return b(__VA_ARGS__); } else { return nilReturnValue; }

// perform Selector
#define performSelector(T, S, ...)  \
if (T && [(NSObject *)T respondsToSelector:S]) \
{   \
    [(NSObject *)T performSelector:S withObjects:__VA_ARGS__];  \
}

// perform Selector
#define performReturnValueSelector(T, S, ...) \
if (T && [(NSObject *)T respondsToSelector:S]) \
{   \
    return [(NSObject *)T performSelector:S withObjects:__VA_ARGS__];   \
}

#endif /* HWDefines_h */
