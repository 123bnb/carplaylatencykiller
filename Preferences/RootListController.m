#import <UIKit/UIKit.h>

// Preferences.framework 是新版 Xcode SDK 不再自带的私有框架，且无需链接——
// 设置页运行在 Preferences.app 进程内，PSListController 由它运行时提供。
// 这里自声明所需接口，链接用 -undefined dynamic_lookup 放行未定义符号。
@interface PSListController : UIViewController
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface RootListController : PSListController {
    NSArray *_specifiers;
}
@end

@implementation RootListController

- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }
    return _specifiers;
}

@end
