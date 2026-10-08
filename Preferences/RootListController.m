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

// 诊断用：不依赖 plist，直接放一段醒目红字，确认我们的 controller 是否真的在显示。
- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 340, 220)];
    testLabel.numberOfLines = 0;
    testLabel.text = @"【诊断】如果你能看到这段红色文字，说明设置页 controller 已正常加载，问题只在 Root.plist；如果看不到，说明系统显示的不是我们的 controller。";
    testLabel.textColor = [UIColor redColor];
    testLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:testLabel];
}

@end
