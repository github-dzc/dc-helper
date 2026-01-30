/**
 * WeChat Helper - 微信增强插件（类似黄白助手）
 * 注入目标：com.tencent.xin
 * 支持在「设置」中开关：防撤回等
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static NSString *const kWeChatHelperPrefsDomain = @"com.ccnetlink.wechathelper";
static NSString *const kRevokeEnabledKey = @"RevokeEnabled";

// 读取「防撤回」是否开启（与 PreferenceLoader 设置页一致）
static BOOL isRevokeEnabled(void) {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:
        [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", kWeChatHelperPrefsDomain]];
    if (!prefs) return YES; // 默认开启
    id v = prefs[kRevokeEnabledKey];
    return (v == nil) ? YES : [v boolValue];
}

// 微信消息管理类（逆向所得，不同版本类名可能略有差异）
@interface CMessageMgr : NSObject
- (void)onRevokeMsg:(id)msg;
@end

%hook CMessageMgr

- (void)onRevokeMsg:(id)msg {
    if (isRevokeEnabled()) {
        // 用户开启了防撤回：不执行原方法，消息不会被撤回
        return;
    }
    %orig;
}

%end

%ctor {
    NSLog(@"[WeChatHelper] 插件已加载 - 防撤回等设置请在「设置 -> WeChat Helper」中开关");
}
