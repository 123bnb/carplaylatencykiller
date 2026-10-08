#import <UIKit/UIKit.h>

// Preferences.framework 是新版 Xcode SDK 不再自带的私有框架，且无需链接——
// 设置页运行在 Preferences.app 进程内，PSListController 由它运行时提供。
// 这里自声明所需接口，链接用 -undefined dynamic_lookup 放行未定义符号。
@interface PSListController : UIViewController
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

// 注意：不要使用 _specifiers 这个变量名——它会与运行时父类 PSListController
// 自带的 _specifiers 同名冲突，导致系统列表读到空。这里用独立变量名缓存。
@interface RootListController : PSListController {
    NSArray *_cachedSpecs;
}
@end

@implementation RootListController

- (id)specifiers {
    if (_cachedSpecs == nil) {
        _cachedSpecs = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }
    return _cachedSpecs;
}

@end
