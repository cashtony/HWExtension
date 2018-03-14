//
//  HWRouter.h
//  HWExtension
//
//  Created by houwen.wang on 2017/5/5.
//  Copyright © 2017年 houwen.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLRoutes.h"
#import "NSString+Category.h"
#import "NSObject+Category.h"
#import "UIApplication+Category.h"

/*!
 
 以open URL 方式跳转到另外一个UIViewController, 以这种方式跳转到一个UIViewController, URL应该符合以下规则:
 
 module://vcName?key1=value1&key2=value2&key3=value3&key4=value4...
 
 module     : @required, 模块名, 如果想从web或其它app跳转, 必须是 info.plist中配置的scheme
 vcName     : @required, 想要跳转的 vc 类名
 key=value  : @optional, 参数
 
 tip: URL 中可带以下参数来控制跳转过程
 
 showType = auto/push/present
 animated = 0/1
 
 如果URL中未设置showType／animated相关参数: showType default is auto, animated default is 1
 
 */

typedef NSString * HWRouteURLParametersKey;
typedef NSString * HWRouteURLParametersShowTypeValue;
typedef NSString * HWRouteURLParametersAnimatedValue;

typedef NS_ENUM(NSInteger, HWRouteActionPolicy) {
    HWRouteActionPolicyCancel,
    HWRouteActionPolicyAllow,
};

typedef NS_ENUM(NSInteger, HWRouteActionErrorDomain) {
    HWRouteActionErrorUnknown,
    HWRouteActionErrorAppRootVCNil,
    HWRouteActionErrorInvalidVCName,
};

@interface HWRouteOptions : NSObject

// 是否动画, default is @"1"
@property (nonatomic, copy) HWRouteURLParametersAnimatedValue animated;

// 展示方式 auto/push/present, default is HWRouteURLParametersShowTypeAuto
@property (nonatomic, copy) HWRouteURLParametersShowTypeValue showType;

// 参数, default is nil
@property (nonatomic, strong) NSDictionary <NSString *, id>*parameters;

// 从哪个ViewController push／present展示, if nil, current visible viewController will push/present
@property (nonatomic, strong) UIViewController *sourceViewController;

+ (instancetype)routeOptions;               // showType = auto / animated = 1
+ (instancetype)routeOptionsNoAnimated;     // showType = auto / animated = 0
+ (instancetype)routeOptionsPush;           // showType = push / animated = 1
+ (instancetype)routeOptionsPresent;        // showType = present / animated = 1

+ (instancetype)routeOptionsPushWithParameters:(NSDictionary <NSString *, id>*)para;
+ (instancetype)routeOptionsPushWithParameters:(NSDictionary <NSString *, id>*)para sourceViewController:(UIViewController *)svc;
+ (instancetype)routeOptionsPresentWithParameters:(NSDictionary <NSString *, id>*)para;
+ (instancetype)routeOptionsPresentWithParameters:(NSDictionary <NSString *, id>*)para sourceViewController:(UIViewController *)svc;

@end

typedef NSString *(^HWRouterReplaceKeyBlock)(NSString *keyInURL);

@interface HWRouter : NSObject

// 注册模块
+ (void)registerModules:(NSArray <NSString *>*)modules;

// route 错误时被调用
@property (class , nonatomic, copy) void (^routerErrorHandler)(NSDictionary *params, NSError *error);

// HWRouter 拦截到一个URL跳转时会调用次方法，调用者可以将url中的vc名重新映射
@property (class, nonatomic, copy) HWRouterReplaceKeyBlock replaceVCNameBlock;

// 用URL的方式跳转到一个UIViewController, options 中设置的参数会覆盖URL中设置了相同key的value
+ (void)routeURL:(NSURL *)url options:(HWRouteOptions *)options;

// 跳转到一个UIViewController
+ (void)routeToViewController:(Class)vc options:(HWRouteOptions *)options;

@end

@protocol HWRouteDelegate <NSObject>

@required

// 允许被router赋值的属性名
+ (NSArray <NSString *>*)publicPropertyNames;

@optional

// 是否需要响应 route 事件
+ (HWRouteActionPolicy)decidePolicyForRouteWithParameters:(NSDictionary<NSString *,id> *)parameters module:(NSString *)module;

// 对URL中的参数名重新映射
+ (NSString *)replacedParameterNameForParameterNameInURL:(NSString *)parameterNameInURL;

@end

@interface UIViewController (HWRouter) <HWRouteDelegate>

// 是否需要响应 route 事件, default return HWRouteActionPolicyAllow
+ (HWRouteActionPolicy)decidePolicyForRouteWithParameters:(NSDictionary<NSString *,id> *)parameters module:(NSString *)module;

// 对URL中的参数名重新映射, default return parameterNameInURL
+ (NSString *)replacedParameterNameForParameterNameInURL:(NSString *)parameterNameInURL;

// 允许被router赋值的属性名, default return nil
+ (NSArray <NSString *>*)publicPropertyNames;

@end

typedef NSString *HWSystemViewPath NS_EXTENSIBLE_STRING_ENUM;

@interface HWRouter (SystemView)

+ (void)routeToSystemViewWithPath:(HWSystemViewPath)path;

@end

// parameters key
UIKIT_EXTERN HWRouteURLParametersKey const HWRouteURLParametersShowTypeKey; // 展示方式key, @"showType"
UIKIT_EXTERN HWRouteURLParametersKey const HWRouteURLParametersAnimatedKey; // 是否动画key, @"animated"

// showType value
UIKIT_EXTERN HWRouteURLParametersShowTypeValue const HWRouteURLParametersShowTypeAuto;       // @"auto"
UIKIT_EXTERN HWRouteURLParametersShowTypeValue const HWRouteURLParametersShowTypePush;       // @"push"
UIKIT_EXTERN HWRouteURLParametersShowTypeValue const HWRouteURLParametersShowTypePresent;    // @'present"

// animated value
UIKIT_EXTERN HWRouteURLParametersAnimatedValue const HWRouteURLParametersAnimatedAnimated;    // @"1"
UIKIT_EXTERN HWRouteURLParametersAnimatedValue const HWRouteURLParametersAnimatedNoAnimated;  // @"0"

// system view path
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathAppSettings NS_AVAILABLE_IOS(8_0);  // appSettings
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathSystemSettings;                     // systemSettings
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathWifi;                               // WI-FI
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathBluetooth;                          // 蓝牙
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathInternetTethering;                  // 个人热点
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathCarrier;                            // 运营商
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathNotifications;                      // 通知
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathDoNotDisturb;                       // 睡眠
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathGeneral;                            // 通用
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathDisplayAndBrightness;               // 调节亮度
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathWallpaper;                          // 墙纸
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathSounds;                             // 声音
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathSiri;                               // siri语音助手
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathPrivacy;                            // 隐私
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathPhone;                              // 电话
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathICloud;                             // icloud
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathStore;                              // iTunes Strore
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathSafari;                             // safari
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathAbout;                              // 关于本机
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathSoftwareUpdateLink;                 // 软件更新
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathAccessibility;                      // 辅助功能
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathDateAndTime;                        // 日期与时间
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathKeyboard;                           // 键盘
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathStorageAndBackup;                   // 存储空间
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathLanguageAndRegion;                  // 语言与地区
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathVPN;                                // VPN
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathManagedConfigurationList;           // 描述文件与设备管理
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathMusic;                              // 音乐
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathNotes;                              // 备忘录
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathPhotos;                             // 照片与相机
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathReset;                              // 还原
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathTwitter;                            // Twiter
UIKIT_EXTERN HWSystemViewPath const HWSystemViewPathFacebook;                           // Facebook

