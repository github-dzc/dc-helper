# DC Helper - 类似黄白助手的微信增强插件
# 需在 macOS 上安装 Theos: https://theos.dev

# 未设置 THEOS 时会报错 "No such file or directory /makefiles/common.mk"
ifndef THEOS
$(error THEOS 未设置。请先安装 Theos，再执行: export THEOS=/opt/theos)
endif

export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64

# 根less 越狱（Dopamine / palera1n rootless 等）：用官方 scheme，deb 会装到 /var/jb，无需传 PREFIX
# 传统越狱请注释掉下一行并 make clean 后重新 make package
export THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DCHelper

DCHelper_FILES = Tweak.xm
DCHelper_CFLAGS = -fobjc-arc
DCHelper_FRAMEWORKS = UIKit Foundation
DCHelper_EXTRA_FRAMEWORKS =
# 链接 C++ 运行时，否则会报 Undefined symbols: ___gxx_personality_v0（.xm 预处理器会用到 C++）
DCHelper_LDFLAGS = -lc++

include $(THEOS_MAKE_PATH)/tweak.mk

# THEOS_PACKAGE_SCHEME=rootless 时 Theos 可能仍设 PREFIX，导致 /var/jbclang；强制用本机工具链
ifneq ($(PREFIX),)
override TARGET_CC := $(shell xcrun -sdk iphoneos -f clang 2>/dev/null)
override TARGET_CXX := $(shell xcrun -sdk iphoneos -f clang++ 2>/dev/null)
override TARGET_LD := $(shell xcrun -sdk iphoneos -f clang 2>/dev/null)
endif

# 安装 PreferenceLoader 设置页（DCHelperPrefs.plist -> 设置里「DC Helper」入口，rootless 时装到 /var/jb/Library/PreferenceLoader/...）
_STAGING_PREFIX := $(if $(THEOS_PACKAGE_INSTALL_PREFIX),$(THEOS_PACKAGE_INSTALL_PREFIX)/,)
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/$(_STAGING_PREFIX)Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp DCHelperPrefs.plist $(THEOS_STAGING_DIR)/$(_STAGING_PREFIX)Library/PreferenceLoader/Preferences/DCHelper.plist$(ECHO_END)

after-install::
	install.exec "killall -9 WeChat 2>/dev/null || true"
