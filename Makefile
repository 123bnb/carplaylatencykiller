# CarPlayLatencyKiller — iOS 16 / RootHide (rootless) 精简版
# 目标：仅 CarPlay 环境下，对指定 App 做“音频预热 + 可选低延迟路径”，
#       消除抖音等视频 App 在无线 CarPlay 上的“出声慢 / 音画延迟”问题。

# 用 theos/sdks 的 patched iPhoneOS16.5.sdk（CI 已下载），它含 Preferences
# 私有框架/头（新版 Xcode SDK 已删除）。deployment 15.0 保证兼容 iOS 16.4.1。
TARGET := iphone:clang:16.5:15.0
INSTALL_TARGET_PROCESSES := SpringBoard

# RootHide 必须用 roothide scheme（配合 roothide Theos fork）编译，
# 这样 deb 才带 .jbroot 加载路径，Sileo 才会识别为 roothide 插件。
# 普通 rootless 包会被 Sileo 拒绝，且转换工具不可靠。
THEOS_PACKAGE_SCHEME := roothide

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CarPlayLatencyKiller

# 主逻辑注入到“可能发声的 App”进程。
# 说明：为保证“预热 + 低延迟路径”能覆盖抖音等前台播放的 App，通常将其注入目标 App 进程。
# 但为通用起见，这里默认同时注入所有 App（全局生效），由运行时“CarPlay + 白名单”开关决定是否干预。
CarPlayLatencyKiller_FILES = Tweak.x
CarPlayLatencyKiller_CFLAGS = -fobjc-arc -Wno-unused-variable
CarPlayLatencyKiller_PRIVATE_FRAMEWORKS = MediaPlayer

include $(THEOS_MAKE_PATH)/tweak.mk

# 设置页：由 Preferences 子工程编译成可执行 bundle（RootListController）。
SUBPROJECTS += Preferences

include $(THEOS_MAKE_PATH)/aggregate.mk
