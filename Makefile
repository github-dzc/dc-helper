# WeChat Helper - 类似黄白助手的微信增强插件
# 需在 macOS 上安装 Theos: https://theos.dev

# 未设置 THEOS 时会报错 "No such file or directory /makefiles/common.mk"
ifndef THEOS
$(error THEOS 未设置。请先安装 Theos，再执行: export THEOS=/opt/theos)
endif

export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64

# 根less 越狱（Dopamine / palera1n rootless 等）需安装到 /var/jb，否则会报 Read-only file system
# 传统越狱可打包时覆盖：make package PREFIX=/
export PREFIX = /var/jb

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
