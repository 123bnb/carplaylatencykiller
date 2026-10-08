# CarPlay Latency Killer（精简版）

针对 **iOS 16 + RootHide / rootless** 的越狱插件：**仅在 CarPlay 环境下**，对指定 App
做“音频预热 + 可选低延迟路径”，消除抖音等视频 App 在**无线 CarPlay** 上的“出声慢 /
音画延迟”（你实测的 2-3 秒才响）。

> 非 CarPlay 环境（扬声器、普通蓝牙、耳机）以及未配置的 App：插件**完全不干预**。

## 它解决什么

| 问题 | 手段 | 默认 |
|---|---|---|
| 首次出声慢 / 2-3 秒才响 | 预热：提前激活 `AVAudioSession` 并预建立 CarPlay 音频流 | 开 |
| 持续延迟（~1.1s 量级） | 切 `voicePrompt` 等低延迟协商路径 | 关（实验） |

依据（公开实测，非本插件独占）：
- 预热 workaround（首音慢）在 Apple 开发者论坛被证实有效。
- 无线 CarPlay 通过更换 `category/mode` 可协商更低延迟路径。

## 目录结构

```
CarPlayLatencyKiller/
├── Makefile                     # Theos / rootless 构建
├── control                      # 包元信息
├── Tweak.x                      # 核心 Logos 逻辑
├── layout/                      # 安装到设备的资源
│   └── Library/
│       ├── MobileSubstrate/DynamicLibraries/     # 主 dylib（由 make 生成）
│       ├── PreferenceLoader/Preferences/         # 设置页入口
│       └── PreferenceBundles/CarPlayLatencyKiller.bundle/  # 设置页界面
├── .github/workflows/build.yml  # GitHub Actions 一键编译
└── Resources/
```

## 编译（推荐 GitHub Actions）

1. 把工程推到你的 GitHub 仓库；
2. 触发 `Build` workflow（或 push），在 **Actions → 该任务 → Artifacts** 下载 `.deb`。

也可以本地 Theos 编译：

```bash
make clean package FINALPACKAGE=1
```

产物在 `packages/*.deb`。

## 安装与使用

1. 用 Sileo / Zebra 安装 `.deb`（RootHide 环境）；
2. **respring** 生效；
3. 到 **设置 → CarPlay Latency Killer**：
   - `应用到所有 App`：若希望所有在 CarPlay 下出声的 App 都受益，打开；
   - `白名单 App`：不打开上面时，逗号分隔填 Bundle ID，如 `com.ss.iphone.ugc.Ame`（抖音）；
   - `启用预热`：保持开启；
   - `启用低延迟路径`：默认关，实车尝试后按需开，异常就关。
4. 改动设置后，**重新打开一次对应 App** 让新配置生效。

## 生效范围与开关逻辑

插件全局注入到各 App 进程，但所有干预都受两个条件约束：

```
生效 = 当前音频输出是 CarPlay  &&  该 App 在白名单内
```

- 判断用公开端口类型 `AVAudioSessionPortCarAudio`；
- 非 CarPlay、非白名单 → 直接调用系统原实现，零干预。

## 已知边界与调试

- **预热**能大幅缩短“首次出声”，但不能 100% 消除；无线那层传输延迟无法归零。
- **低延迟路径**可能带来单声道 / 录音通道 / App 行为异常等副作用，且不同车型表现不同，
  务必实机逐个尝试；这是本插件唯一默认关闭的开关。
- 查看是否生效：用 `log stream --predicate 'eventMessage CONTAINS "CarPlayLatencyKiller"'`，
  看 `prewarm done ... route=CarAudio` 是否出现。

## 需要你替换的占位

- `control` 和 plist 里的 `com.yourname.carplaylatencykiller` → 换成你自己的包 ID；
- `Maintainer / Author` 字段。
