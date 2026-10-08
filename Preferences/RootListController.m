#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface RootListController : PSListController
@end

@implementation RootListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

// 增强诊断：把 bundle / Root.plist / specifier 加载情况直接显示在页面上。
- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableString *info = [NSMutableString string];
    NSBundle *b = [NSBundle bundleForClass:[self class]];
    [info appendFormat:@"1) bundlePath:\n%@\n\n", b.bundlePath];

    NSString *path = [b pathForResource:@"Root" ofType:@"plist"];
    [info appendFormat:@"2) pathForResource Root.plist: %@\n\n", path ? @"找到了" : @"NIL（找不到）"];

    if (path) {
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
        [info appendFormat:@"3) plist 顶层键: %@\n", plist.allKeys];
        NSArray *specs = plist[@"PreferenceSpecifiers"];
        [info appendFormat:@"   PreferenceSpecifiers 数量: %lu\n\n", (unsigned long)specs.count];
    }

    NSArray *loaded = [self loadSpecifiersFromPlistName:@"Root" target:self];
    [info appendFormat:@"4) loadSpecifiersFromPlistName 返回数量: %lu\n\n", (unsigned long)loaded.count];

    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:b.bundlePath error:nil];
    [info appendFormat:@"5) bundle 目录实际内容:\n%@\n", contents];

    // 也查一下 Resources 子目录
    NSString *resDir = [b.bundlePath stringByAppendingPathComponent:@"Resources"];
    NSArray *resContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resDir error:nil];
    [info appendFormat:@"\n6) Resources 子目录: %@\n", resContents ?: @"不存在"];

    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, self.view.bounds.size.height - 70)];
    tv.text = info;
    tv.font = [UIFont systemFontOfSize:11];
    tv.editable = NO;
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tv];
}

@end
