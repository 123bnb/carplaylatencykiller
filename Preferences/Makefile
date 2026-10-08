# Preferences 设置页子工程
# 生成 CarPlayLatencyKiller.bundle（含可执行 RootListController），
# 这样设置页才能被 Preferences 正常显示。

TARGET := iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME := roothide

include $(THEOS_MAKE_PATH)/common.mk

BUNDLE_NAME = CarPlayLatencyKiller

CarPlayLatencyKiller_FILES = RootListController.m
CarPlayLatencyKiller_INSTALL_PATH = /Library/PreferenceBundles
# 不链接 Preferences.framework（新版 Xcode SDK 已不含该私有框架），
# 设置页运行在 Preferences.app 进程内，PSListController 由它运行时提供。
CarPlayLatencyKiller_LDFLAGS = -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/bundle.mk
