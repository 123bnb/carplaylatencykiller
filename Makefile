# CarPlayLatencyKiller — iOS 16 / RootHide (rootless) 精简版
# 目标：仅 CarPlay 环境下，对指定 App 做“音频预热 + 可选低延迟路径”，
#       消除抖音等视频 App 在无线 CarPlay 上的“出声慢 / 音画延迟”问题。

TARGET := iphone:clang:16.0:15.0
INSTALL_TARGET_PROCESSES := SpringBoard

# RootHide 使用 rootless 架构（/var/jb）。若你的环境是纯 rootless 也一致。
THEOS_PACKAGE_SCHEME := rootless

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
# 设置页使用纯 plist 资源（layout/ 下），无需独立编译子工程。
include $(THEOS_MAKE_PATH)/aggregate.mk
