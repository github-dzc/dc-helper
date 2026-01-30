/**
 * DC Helper - 微信增强插件（类似黄白助手）
 * 注入目标：com.tencent.xin
 * 支持在「设置 -> DC Helper」中开关：防撤回等
 * 仅在微信进程内初始化 Hook，避免误注入导致 Safe Mode
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static NSString *const kDCHelperPrefsDomain = @"com.ccnetlink.dchelper";
static NSString *const kRevokeEnabledKey = @"RevokeEnabled";
static NSString *const kWeChatBundleID = @"com.tencent.xin";

// 读取「防撤回」是否开启（rootless 下优先读 /var/jb 前缀路径）
static BOOL isRevokeEnabled(void) {
    NSArray *paths = @[
        @"/var/mobile/Library/Preferences/com.ccnetlink.dchelper.plist",
        @"/var/jb/var/mobile/Library/Preferences/com.ccnetlink.dchelper.plist"
    ];
    for (NSString *path in paths) {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:path];
        if (prefs) {
            id v = prefs[kRevokeEnabledKey];
            return (v == nil) ? YES : [v boolValue];
        }
    }
    return YES; // 默认开启
}

// 微信消息管理类（逆向所得，不同版本类名可能略有差异）
@interface CMessageMgr : NSObject
- (void)onRevokeMsg:(id)msg;
@end

%group WeChatOnly

%hook CMessageMgr

- (void)onRevokeMsg:(id)msg {
    if (!msg) { %orig; return; }
    if (isRevokeEnabled()) {
        return; // 防撤回：不执行原方法
    }
    %orig;
}

%end

%end

%ctor {
    // 仅在微信进程内初始化 Hook，避免被注入到 SpringBoard 等导致 Safe Mode
    if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:kWeChatBundleID])
        return;
    %init(WeChatOnly);
}
