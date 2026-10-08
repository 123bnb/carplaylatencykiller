# Preferences 设置页子工程
# 生成 CarPlayLatencyKiller.bundle（含可执行 RootListController）。
# 用 patched iPhoneOS16.5.sdk 的真 Preferences 私有框架（含头文件），开 ARC，
# 完全对齐能正常显示设置页的 NotificationsGroupCount 工程写法。

TARGET := iphone:clang:16.5:15.0
THEOS_PACKAGE_SCHEME := roothide
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/common.mk

BUNDLE_NAME = CarPlayLatencyKiller

CarPlayLatencyKiller_FILES = RootListController.m
CarPlayLatencyKiller_FRAMEWORKS = UIKit
CarPlayLatencyKiller_PRIVATE_FRAMEWORKS = Preferences
CarPlayLatencyKiller_INSTALL_PATH = /Library/PreferenceBundles
CarPlayLatencyKiller_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
