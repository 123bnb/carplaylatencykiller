# Preferences 设置页子工程
# 生成 CarPlayLatencyKiller.bundle（含可执行 RootListController），
# 这样设置页才能被 Preferences 正常显示。

TARGET := iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME := roothide

include $(THEOS_MAKE_PATH)/common.mk

BUNDLE_NAME = CarPlayLatencyKiller

CarPlayLatencyKiller_FILES = RootListController.m
CarPlayLatencyKiller_INSTALL_PATH = /Library/PreferenceBundles
CarPlayLatencyKiller_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk
