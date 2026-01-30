# WeChat Helper - 类似黄白助手的微信增强插件
# 需在 macOS 上安装 Theos: https://theos.dev

export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatHelper

WeChatHelper_FILES = Tweak.xm
WeChatHelper_CFLAGS = -fobjc-arc
WeChatHelper_FRAMEWORKS = UIKit Foundation
WeChatHelper_EXTRA_FRAMEWORKS = 

include $(THEOS_MAKE_PATH)/tweak.mk

# 安装 PreferenceLoader 设置页（设置 -> WeChat Helper）
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp WeChatHelperPrefs.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WeChatHelper.plist$(ECHO_END)

after-install::
	install.exec "killall -9 WeChat 2>/dev/null || true"
