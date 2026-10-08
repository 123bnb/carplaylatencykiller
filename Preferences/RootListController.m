#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface RootListController : PSListController
@end

@implementation RootListController

// 手动构建 specifier，绕过在本机返回 0 的 loadSpecifiersFromPlistName。
- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *built = [NSMutableArray array];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *path = [bundle pathForResource:@"Root" ofType:@"plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];

        for (NSDictionary *entry in plist[@"PreferenceSpecifiers"]) {
            NSString *cellStr = entry[@"cell"];
            PSCellType cellType = PSLinkCell;
            if ([cellStr isEqualToString:@"PSGroupCell"]) cellType = PSGroupCell;
            else if ([cellStr isEqualToString:@"PSSwitchCell"]) cellType = PSSwitchCell;
            else if ([cellStr isEqualToString:@"PSEditTextCell"]) cellType = PSEditTextCell;

            PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:entry[@"label"]
                                                              target:self
                                                                 set:@selector(setPreferenceValue:specifier:)
                                                                 get:@selector(readPreferenceValue:)
                                                              detail:Nil
                                                                cell:cellType
                                                                edit:Nil];
            if (spec) {
                [spec setProperties:[entry mutableCopy]];
                [built addObject:spec];
            }
        }
        _specifiers = built;
    }
    return _specifiers;
}

// 临时诊断：显示手动构建出的数量。
- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *diag = [[UILabel alloc] initWithFrame:CGRectMake(16, 90, 340, 60)];
    diag.numberOfLines = 0;
    diag.text = [NSString stringWithFormat:@"手动构建 specifier 数量：%lu", (unsigned long)self.specifiers.count];
    diag.textColor = [UIColor redColor];
    diag.font = [UIFont boldSystemFontOfSize:15];
    [self.view addSubview:diag];
}

@end
