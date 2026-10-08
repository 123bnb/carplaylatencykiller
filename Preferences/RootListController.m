#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

// 标准设置页 controller：从 bundle 的 Root.plist 加载设置项。
// 用 patched SDK 的真 Preferences 头 + ARC，与能正常显示的工程写法一致。
@interface RootListController : PSListController
@end

@implementation RootListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

@end
