//
//  HWRoute.m
//  HWExtension
//
//  Created by houwen.wang on 2017/5/5.
//  Copyright © 2017年 houwen.wang. All rights reserved.
//

#import "HWRouter.h"

NSString *const HWRouteOptionsKey = @"HWRouteOptions";
NSString *const HWRouteExceptionName = @"HWRouteException";

@interface NSDictionary (HWRouter)

// 替换 key
- (NSDictionary *)replacedKeyDictionary:(id)originalKey toKey:(id)toKey;

@end

@interface NSMutableDictionary (HWRouter)

// 替换 key
- (void)replacedKey:(id)originalKey toKey:(id)toKey;

@end

@implementation NSDictionary (HWRouter)

// 替换 key
- (NSDictionary *)replacedKeyDictionary:(id)originalKey toKey:(id)toKey {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self];
    [dic replacedKey:originalKey toKey:toKey];
    return [NSDictionary dictionaryWithDictionary:dic];
}

@end

@implementation NSMutableDictionary (HWRouter)

// 替换 key
- (void)replacedKey:(id)originalKey toKey:(id)toKey {
    if (originalKey == nil ||
        toKey == nil ||
        ![self.allKeys containsObject:originalKey] ||
        [self.allKeys containsObject:toKey] ||
        [originalKey isEqual:toKey]) return;
    
    id value = self[originalKey];
    self[toKey] = value;
    [self removeObjectForKey:originalKey];
}

@end

@interface UIViewController (_HWRouter)

+ (UIViewController *)visibleViewControllerFrom:(UIViewController *)vc;
+ (UIWindow *)applicationKeyWindow;

@end

@implementation UIViewController (_HWRouter)

+ (UIViewController *)visibleViewControllerFrom:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self visibleViewControllerFrom:[((UINavigationController *)vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self visibleViewControllerFrom:[((UITabBarController *)vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self visibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

+ (UIWindow *)applicationKeyWindow {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    return window;
}

@end

@implementation HWRouteOptions

- (instancetype)init {
    if (self=[super init]) {
        self.animated = HWRouteURLParametersAnimatedAnimated;
        self.showType = HWRouteURLParametersShowTypeAuto;
    }
    return self;
}

+ (instancetype)routeOptions {
    return [[self alloc] init];
}

+ (instancetype)routeOptionsNoAnimated {
    HWRouteOptions *opt = [[self alloc] init];
    opt.animated = HWRouteURLParametersAnimatedNoAnimated;
    return opt;
}

+ (instancetype)routeOptionsPush {
    return [self routeOptionsPushWithParameters:nil sourceViewController:nil];
}

+ (instancetype)routeOptionsPushWithParameters:(NSDictionary <NSString *, id>*)para {
    return [self routeOptionsPushWithParameters:para sourceViewController:nil];
}

+ (instancetype)routeOptionsPushWithParameters:(NSDictionary <NSString *, id>*)para sourceViewController:(UIViewController *)svc {
    HWRouteOptions *opt = [[self alloc] init];
    opt.showType = HWRouteURLParametersShowTypePush;
    opt.parameters = para;
    opt.sourceViewController = svc;
    return opt;
}

+ (instancetype)routeOptionsPresent {
    return [self routeOptionsPresentWithParameters:nil sourceViewController:nil];
}

+ (instancetype)routeOptionsPresentWithParameters:(NSDictionary <NSString *, id>*)para {
    return [self routeOptionsPresentWithParameters:para sourceViewController:nil];
}

+ (instancetype)routeOptionsPresentWithParameters:(NSDictionary <NSString *, id>*)para sourceViewController:(UIViewController *)svc {
    HWRouteOptions *opt = [[self alloc] init];
    opt.showType = HWRouteURLParametersShowTypePresent;
    opt.parameters = para;
    opt.sourceViewController = svc;
    return opt;
}

- (NSString *)description {
    return self.keyValueDictionary.description;
}

@end

@implementation HWRouter

#pragma mark - public api

// 注册模块
+ (void)registerModules:(NSArray <NSString *>*)modules {
    for (NSString *module in modules) {
        [self registerModuleWithName:module];
    }
}

+ (void)routeURL:(NSURL *)url options:(HWRouteOptions *)options {
    if (options) {
        [JLRoutes routeURL:url withParameters:@{HWRouteOptionsKey : options}];
        return;
    }
    [JLRoutes routeURL:url withParameters:nil];
}

// 跳转到一个UIViewController
+ (void)routeToViewController:(Class)vc options:(HWRouteOptions *)options {
    [self routeURL:[NSString stringWithFormat:@"HWRouter://VC/%@", NSStringFromClass(vc)].hw_URL options:options];
}

#pragma mark - private methods

const void * _Nonnull __HWReplaceKeyBlockKey__ = &__HWReplaceKeyBlockKey__;
const void * _Nonnull __HWRouterErrorHandlerKey__ = &__HWRouterErrorHandlerKey__;

+ (HWRouterReplaceKeyBlock)replaceVCNameBlock {
    return objc_getAssociatedObject(self, __HWReplaceKeyBlockKey__);
}

+ (void)setReplaceVCNameBlock:(HWRouterReplaceKeyBlock)replaceVCNameBlock {
    objc_setAssociatedObject(self, __HWReplaceKeyBlockKey__, replaceVCNameBlock, OBJC_ASSOCIATION_COPY);
}

+ (void (^)(NSDictionary *, NSError *))routerErrorHandler {
    return objc_getAssociatedObject(self, __HWRouterErrorHandlerKey__);
}

+ (void)setRouterErrorHandler:(void (^)(NSDictionary *, NSError *))routerErrorHandler {
    objc_setAssociatedObject(self, __HWRouterErrorHandlerKey__, routerErrorHandler, OBJC_ASSOCIATION_COPY);
}

+ (NSArray <NSString *>*)excludeKeys {
    static NSArray <NSString *>* excludeKeys = nil;
    if (excludeKeys == nil) {
        excludeKeys = @[JLRoutePatternKey,
                        JLRouteURLKey,
                        JLRouteSchemeKey,
                        JLRouteWildcardComponentsKey,
                        HWRouteOptionsKey,
                        @"vcName"];
    }
    return excludeKeys;
}

// 注册模块
+ (void)registerModuleWithName:(NSString *)moduleName {
    
    if (!moduleName || !moduleName.length) return;
    
    [[JLRoutes routesForScheme:moduleName] addRoute:@":vcName"
                                           priority:0
                                            handler:^BOOL(NSDictionary<NSString *,id> *parameters) {
                                                
                                                NSString *vcName = parameters[@"vcName"];
                                                
                                                if (self.replaceVCNameBlock) {
                                                    NSString *replacedVCName = self.replaceVCNameBlock(vcName);
                                                    if (replacedVCName && replacedVCName.length) {
                                                        vcName = replacedVCName;
                                                    }
                                                }
                                                
                                                if (!vcName || !vcName.length) {
                                                    [self performErrorHandlerBlockWithPatams:parameters error:[NSError errorWithDomain:@"className empty" code:HWRouteActionErrorInvalidVCName userInfo:nil]];
                                                    return NO;
                                                }
                                                
                                                if (vcName) {
                                                    
                                                    Class vcCls = NSClassFromString(vcName);
                                                    
                                                    if (!vcCls || ![vcCls isSubclassOfClass:[UIViewController class]]) {
                                                        [self performErrorHandlerBlockWithPatams:parameters error:[NSError errorWithDomain:@"className error" code:HWRouteActionErrorInvalidVCName userInfo:nil]];
                                                        return NO;
                                                    }
                                                    
                                                    if (vcCls && [vcCls isSubclassOfClass:[UIViewController class]]) {
                                                        
                                                        /* 是否需要响应 route 事件 */
                                                        HWRouteActionPolicy policy;
                                                        if ([vcCls respondsToSelector:@selector(decidePolicyForRouteWithParameters:module:)]) {
                                                            policy = [vcCls decidePolicyForRouteWithParameters:parameters module:parameters[JLRouteSchemeKey]];
                                                        } else {
                                                            policy = HWRouteActionPolicyAllow;
                                                        }
                                                        if (policy == HWRouteActionPolicyCancel) return YES;
                                                        
                                                        /* 需要响应 */
                                                        UIViewController *sourceViewController = nil;
                                                        
                                                        HWRouteOptions *options = parameters[HWRouteOptionsKey];
                                                        if (options) {
                                                            sourceViewController = options.sourceViewController;
                                                        }
                                                        
                                                        if (sourceViewController == nil) {
                                                            sourceViewController = [UIViewController visibleViewControllerFrom:[UIViewController applicationKeyWindow].rootViewController];
                                                        }
                                                        
                                                        if (!sourceViewController) {
                                                            [self performErrorHandlerBlockWithPatams:parameters error:[NSError errorWithDomain:@"APP keyWindow.rootViewController not set" code:HWRouteActionErrorAppRootVCNil userInfo:nil]];
                                                            return NO;
                                                        }
                                                        
                                                        if (sourceViewController) {
                                                            
                                                            NSMutableDictionary *parameters_inURL = [NSMutableDictionary dictionary];
                                                            for (NSString *parameter in parameters.allKeys) {
                                                                if ([[self excludeKeys] containsObject:parameter]) continue;
                                                                parameters_inURL[parameter] = [parameters[parameter] copy];
                                                            }
                                                            
                                                            /* key 重新 map */
                                                            if ([vcCls respondsToSelector:@selector(replacedParameterNameForParameterNameInURL:)]) {
                                                                for (NSString *URLParameter in parameters_inURL.allKeys) {
                                                                    NSString *replacedParameter = [vcCls replacedParameterNameForParameterNameInURL:URLParameter];
                                                                    [parameters_inURL replacedKey:URLParameter toKey:replacedParameter];
                                                                }
                                                            }
                                                            
                                                            NSMutableDictionary *parameters_all = [[NSMutableDictionary alloc] initWithDictionary:parameters_inURL];
                                                            if (options && options.parameters && options.parameters.count) {
                                                                [parameters_all addEntriesFromDictionary:options.parameters];
                                                            }
                                                            
                                                            UIViewController *targetVC = [[vcCls alloc] init];
                                                            
                                                            if ([vcCls respondsToSelector:@selector(publicPropertyNames)]) {
                                                                
                                                                NSArray <NSString *>*publicPropertyNames = [vcCls publicPropertyNames];
                                                                
                                                                for (NSString *propertyName in publicPropertyNames) {
                                                                    [targetVC setValue:parameters_all[propertyName] forKey:propertyName];
                                                                }
                                                            }
                                                            
                                                            HWRouteURLParametersShowTypeValue showType = parameters_all[HWRouteURLParametersShowTypeKey] ?
                                                            parameters_all[HWRouteURLParametersShowTypeKey] :
                                                            HWRouteURLParametersShowTypeAuto;
                                                            
                                                            HWRouteURLParametersAnimatedValue animatedValue = parameters_all[HWRouteURLParametersAnimatedKey] ?
                                                            parameters_all[HWRouteURLParametersAnimatedKey] :
                                                            HWRouteURLParametersAnimatedAnimated;
                                                            
                                                            BOOL animated = animatedValue.integerValue;
                                                            
                                                            if ([showType.lowercaseString isEqualToString:HWRouteURLParametersShowTypePush]) {
                                                                if (sourceViewController.navigationController) {
                                                                    [sourceViewController.navigationController pushViewController:targetVC animated:animated];
                                                                }
                                                            } else if ([showType.lowercaseString isEqualToString:HWRouteURLParametersShowTypePresent]) {
                                                                [sourceViewController presentViewController:targetVC animated:animated completion:nil];
                                                            } else {
                                                                if (sourceViewController.navigationController) {
                                                                    [sourceViewController.navigationController pushViewController:targetVC animated:animated];
                                                                } else {
                                                                    [sourceViewController presentViewController:targetVC animated:animated completion:nil];
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                return YES;
                                            }];
}

+ (void)performErrorHandlerBlockWithPatams:(NSDictionary *)params error:(NSError *)error {
    if (self.routerErrorHandler) {
        self.routerErrorHandler(params, error);
    }
}

@end

@implementation UIViewController (HWRouter)

#pragma mark - HWRouteDelegate

// 对URL中的参数名重新映射
+ (NSString *)replacedParameterNameForParameterNameInURL:(NSString *)parameterNameInURL {
    return parameterNameInURL;
}

// 是否需要响应 route 事件
+ (HWRouteActionPolicy)decidePolicyForRouteWithParameters:(NSDictionary<NSString *,id> *)parameters module:(NSString *)module {
    return HWRouteActionPolicyCancel;
}

// 允许被router赋值的属性名
+ (NSArray<NSString *> *)publicPropertyNames {
    return nil;
}

#pragma mark -

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"\n \"%@\" hasn't \"%@\" property!!!\n", self.class, key);
    return [NSNull null];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"\n \"%@\" hasn't \"%@\" property!!!\n", self.class, key);
}

@end

@implementation HWRouter (SystemView)

+ (void)routeToSystemViewWithPath:(HWSystemViewPath)path {
    
    if (path && path.length) {
        
        NSString *prefix = @"app-";
        NSString *path_t = [path copy];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            if (![path_t hasPrefix:prefix]) {
                path_t = [prefix stringByAppendingString:path_t];
            }
        } else {
            if ([path_t hasPrefix:prefix]) {
                path_t = [path_t substringFromIndex:4];
            }
        }
        
        NSURL *url = path_t.hw_URL;
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] hw_openURL:url options:nil completionHandler:nil];
        } else {
            NSLog(@"-HWRoute: open system view failed. error: path unavailable");
        }
    } else {
        NSLog(@"-HWRoute: open system view failed. error: path can't be empty");
    }
}

@end

// parameters key
HWRouteURLParametersKey const HWRouteURLParametersShowTypeKey = @"showType"; // 展示方式key
HWRouteURLParametersKey const HWRouteURLParametersAnimatedKey = @"animated"; // 是否动画key

// showType value
HWRouteURLParametersShowTypeValue const HWRouteURLParametersShowTypeAuto = @"auto";        // 自动匹配
HWRouteURLParametersShowTypeValue const HWRouteURLParametersShowTypePush = @"push";        // push
HWRouteURLParametersShowTypeValue const HWRouteURLParametersShowTypePresent = @"present";  // Present

// animated value
HWRouteURLParametersAnimatedValue const HWRouteURLParametersAnimatedAnimated = @"1";    // 有动画效果
HWRouteURLParametersAnimatedValue const HWRouteURLParametersAnimatedNoAnimated = @"0";  // 无动画效果

// system view path
HWSystemViewPath const HWSystemViewPathAppSettings              = @"app-settings:";                                         // appSettings
HWSystemViewPath const HWSystemViewPathSystemSettings           = @"app-Prefs:root=Settings";                               // systemSettings
HWSystemViewPath const HWSystemViewPathWifi                     = @"app-Prefs:root=WIFI";                                   // WI-FI
HWSystemViewPath const HWSystemViewPathBluetooth                = @"app-Prefs:root=Bluetooth";                              // 蓝牙
HWSystemViewPath const HWSystemViewPathInternetTethering        = @"app-Prefs:root=INTERNET_TETHERING";                     // 个人热点
HWSystemViewPath const HWSystemViewPathCarrier                  = @"app-Prefs:root=Carrier";                                // 运营商
HWSystemViewPath const HWSystemViewPathNotifications            = @"app-Prefs:root=NOTIFICATIONS_ID";                       // 通知
HWSystemViewPath const HWSystemViewPathDoNotDisturb             = @"app-Prefs:root=DO_NOT_DISTURB";                         // 睡眠
HWSystemViewPath const HWSystemViewPathGeneral                  = @"app-Prefs:root=General";                                // 通用
HWSystemViewPath const HWSystemViewPathDisplayAndBrightness     = @"app-Prefs:root=DISPLAY&BRIGHTNESS";                     // 调节亮度
HWSystemViewPath const HWSystemViewPathWallpaper                = @"app-Prefs:root=Wallpaper";                              // 墙纸
HWSystemViewPath const HWSystemViewPathSounds                   = @"app-Prefs:root=Sounds";                                 // 声音
HWSystemViewPath const HWSystemViewPathSiri                     = @"app-Prefs:root=SIRI";                                   // siri语音助手
HWSystemViewPath const HWSystemViewPathPrivacy                  = @"app-Prefs:root=Privacy";                                // 隐私
HWSystemViewPath const HWSystemViewPathPhone                    = @"app-Prefs:root=Phone";                                  // 电话
HWSystemViewPath const HWSystemViewPathICloud                   = @"app-Prefs:root=CASTLE";                                 // icloud
HWSystemViewPath const HWSystemViewPathStore                    = @"app-Prefs:root=STORE";                                  // iTunes Strore
HWSystemViewPath const HWSystemViewPathSafari                   = @"app-Prefs:root=SAFARI";                                 // safari
HWSystemViewPath const HWSystemViewPathAbout                    = @"app-Prefs:root=General&path=About";                     // 关于本机
HWSystemViewPath const HWSystemViewPathSoftwareUpdateLink       = @"app-Prefs:root=General&path=SOFTWARE_UPDATE_LINK";      // 软件更新
HWSystemViewPath const HWSystemViewPathAccessibility            = @"app-Prefs:root=General&path=ACCESSIBILITY";             // 辅助功能
HWSystemViewPath const HWSystemViewPathDateAndTime              = @"app-Prefs:root=General&path=DATE_AND_TIME";             // 日期与时间
HWSystemViewPath const HWSystemViewPathKeyboard                 = @"app-Prefs:root=General&path=Keyboard";                  // 键盘
HWSystemViewPath const HWSystemViewPathStorageAndBackup         = @"app-Prefs:root=CASTLE&path=STORAGE_AND_BACKUP";         // 存储空间
HWSystemViewPath const HWSystemViewPathLanguageAndRegion        = @"app-Prefs:root=General&path=Language_AND_Region";       // 语言与地区
HWSystemViewPath const HWSystemViewPathVPN                      = @"app-Prefs:root=General&path=VPN";                       // VPN
HWSystemViewPath const HWSystemViewPathManagedConfigurationList = @"app-Prefs:root=General&path=ManagedConfigurationList";  // 描述文件与设备管理
HWSystemViewPath const HWSystemViewPathMusic                    = @"app-Prefs:root=MUSIC";                                  // 音乐
HWSystemViewPath const HWSystemViewPathNotes                    = @"app-Prefs:root=NOTES";                                  // 备忘录
HWSystemViewPath const HWSystemViewPathPhotos                   = @"app-Prefs:root=Photos";                                 // 照片与相机
HWSystemViewPath const HWSystemViewPathReset                    = @"app-Prefs:root=General&path=Reset";                     // 还原
HWSystemViewPath const HWSystemViewPathTwitter                  = @"app-Prefs:root=TWITTER";                                // Twiter
HWSystemViewPath const HWSystemViewPathFacebook                 = @"app-Prefs:root=FACEBOOK";                               // Facebook

