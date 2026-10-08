// CarPlayLatencyKiller — 精简版
// 目标：仅 CarPlay 环境下，对白名单 App 做两件事：
//   1) 预热：提前激活 AVAudioSession，预解析并建立到 CarPlay 的音频流，
//      消除抖音等视频 App 在无线 CarPlay 上的“首次出声慢 / 2-3 秒才响”。
//   2) 可选低延迟路径：将音频会话 mode 切到 voicePrompt 等低延迟协商路径，
//      把持续延迟从 ~1.1s 量级压到几百 ms（实验性，默认关闭，副作用需真机确认）。
// 关键约束：
//   - 所有干预都包裹在 IsCarPlayActive() 判断里；非 CarPlay 环境一律 %orig 不动，
//     保证扬声器 / 普通蓝牙 / 有线音频下插件完全不干预系统。
//   - 未加入白名单（且未开 applyToAll）的 App 同样完全不干预。

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

// ============ 配置 ============
static NSString *const kPrefsPath =
    @"/var/jb/var/mobile/Library/Preferences/com.yourname.carplaylatencykiller.plist";
static NSString *const kCarPortType = AVAudioSessionPortCarAudio; // "CarAudio"

// ============ 运行时状态 ============
static BOOL gCarPlayActive    = NO;   // 当前输出是否为 CarPlay（由路由变化通知实时更新）
static BOOL gInWhitelist      = NO;   // 当前进程是否命中白名单
static BOOL gEnablePrewarm    = YES;  // 是否启用预热
static BOOL gEnableLowLatency = NO;   // 是否启用低延迟路径（实验，默认关）
static BOOL gApplyToAll       = NO;   // 是否对所有在 CarPlay 下出声的 App 生效
static BOOL gPrewarmed        = NO;   // 本次前台周期是否已预热
static BOOL gInSetActive      = NO;   // 防重入标志

// ============ 工具函数 ============
static NSString *CurrentBundleId(void) {
    return [[NSBundle mainBundle] bundleIdentifier] ?: @"?";
}

static void LoadPrefs(void) {
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    if (!d) d = @{};
    gEnablePrewarm    = (d[@"enablePrewarm"] == nil) ? YES : [d[@"enablePrewarm"] boolValue];
    gEnableLowLatency = [d[@"enableLowLatency"] boolValue];
    gApplyToAll       = [d[@"applyToAll"] boolValue];

    gInWhitelist = gApplyToAll;
    if (!gInWhitelist) {
        NSString *list = d[@"whitelist"] ?: @"";
        NSString *bid  = CurrentBundleId();
        for (NSString *s in [list componentsSeparatedByString:@","]) {
            NSString *t = [s stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (t.length && [t isEqualToString:bid]) { gInWhitelist = YES; break; }
        }
    }
}

static BOOL IsCarPlayActive(void) {
    AVAudioSession *s = [AVAudioSession sharedInstance];
    for (AVAudioSessionPortDescription *p in s.currentRoute.outputs) {
        if ([p.portType isEqualToString:kCarPortType]) return YES;
    }
    return NO;
}

// 核心开关：只有“CarPlay 环境”且“命中白名单”才允许干预。
static BOOL ShouldAct(void) {
    return gCarPlayActive && gInWhitelist;
}

// ============ 预热 ============
// 提前激活会话并让系统解析/建立 CarPlay 音频流；用 Ambient（可混音、不抢占）类别，
// 避免预热时打断正在播放的其它音频。
static void DoPrewarm(void) {
    if (gPrewarmed) return;
    AVAudioSession *s = [AVAudioSession sharedInstance];
    NSString *cat = s.category;
    if (cat == nil || [cat isEqualToString:AVAudioSessionCategorySoloAmbient]) {
        [s setCategory:AVAudioSessionCategoryAmbient
                 mode:AVAudioSessionModeDefault
               options:0 error:nil];
    }
    NSError *err = nil;
    BOOL ok = [s setActive:YES error:&err];
    // 调小 IO 缓冲，尽力缩短协商/缓冲时长（失败不致命）
    [s setPreferredIOBufferDuration:0.005 error:nil];
    gPrewarmed = YES;
    NSLog(@"[CarPlayLatencyKiller] prewarm done ok=%d route=%@ err=%@",
          ok, s.currentRoute.outputs.firstObject.portType, err);
}

static void ResetPrewarm(void) { gPrewarmed = NO; }

// ============ Logos Hooks ============
%hook AVAudioSession

// 现代 App（含抖音）使用的带 routeSharingPolicy 的版本
- (BOOL)setCategory:(NSString *)category mode:(NSString *)mode
  routeSharingPolicy:(AVAudioSessionRouteSharingPolicy)policy
  options:(AVAudioSessionCategoryOptions)options error:(NSError **)outError {
    if (ShouldAct() && gEnableLowLatency) {
        if ([category isEqualToString:AVAudioSessionCategorySoloAmbient])
            category = AVAudioSessionCategoryPlayback;
        // 低延迟协商路径（iOS 12+，iOS 16 支持）
        if (![mode isEqualToString:AVAudioSessionModeVoicePrompt])
            mode = AVAudioSessionModeVoicePrompt;
    }
    return %orig(category, mode, policy, options, outError);
}

- (BOOL)setCategory:(NSString *)category mode:(NSString *)mode
  options:(AVAudioSessionCategoryOptions)options error:(NSError **)outError {
    if (ShouldAct() && gEnableLowLatency) {
        if ([category isEqualToString:AVAudioSessionCategorySoloAmbient])
            category = AVAudioSessionCategoryPlayback;
        if (![mode isEqualToString:AVAudioSessionModeVoicePrompt])
            mode = AVAudioSessionModeVoicePrompt;
    }
    return %orig(category, mode, options, outError);
}

- (BOOL)setCategory:(NSString *)category error:(NSError **)outError {
    if (ShouldAct() && gEnableLowLatency) {
        if ([category isEqualToString:AVAudioSessionCategorySoloAmbient])
            category = AVAudioSessionCategoryPlayback;
    }
    return %orig(category, outError);
}

- (BOOL)setActive:(BOOL)active error:(NSError **)outError {
    // 防重入：内部预热激活时直通原实现，避免无限递归 / 重复激活
    if (gInSetActive) return %orig(active, outError);
    if (active && ShouldAct() && gEnablePrewarm) {
        gInSetActive = YES;
        [self setActive:YES error:nil];   // 递归：gInSetActive=YES → %orig 完成真正激活
        gInSetActive = NO;
        return YES;                        // 预热激活已完成，直接返回，避免外层再重复激活
    }
    return %orig(active, outError);
}

- (BOOL)setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError **)outError {
    if (gInSetActive) return %orig(active, options, outError);
    if (active && ShouldAct() && gEnablePrewarm) {
        gInSetActive = YES;
        [self setActive:YES error:nil];
        gInSetActive = NO;
        return YES;
    }
    return %orig(active, options, outError);
}

%end

// ============ 生命周期与路由监听 ============
static void RegisterNotifications(void) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    // 路由变化 → 实时更新 CarPlay 状态
    [nc addObserverForName:AVAudioSessionRouteChangeNotification object:nil queue:nil
                usingBlock:^(NSNotification *n) {
                    gCarPlayActive = IsCarPlayActive();
                }];

    // 进入前台：重置预热状态并执行一次预热（若条件满足）
    [nc addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil
                usingBlock:^(NSNotification *n) {
                    LoadPrefs();
                    gCarPlayActive = IsCarPlayActive();
                    ResetPrewarm();
                    if (ShouldAct() && gEnablePrewarm) DoPrewarm();
                }];

    // 退到后台：清掉预热标志，下次进前台重新预热
    [nc addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil
                usingBlock:^(NSNotification *n) {
                    ResetPrewarm();
                }];
}

%ctor {
    @autoreleasepool {
        LoadPrefs();
        gCarPlayActive = IsCarPlayActive();
        RegisterNotifications();
        NSLog(@"[CarPlayLatencyKiller] loaded bid=%@ carplay=%d whitelist=%d",
              CurrentBundleId(), gCarPlayActive, gInWhitelist);
    }
}
