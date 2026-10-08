#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface RootListController : PSListController
@end

@implementation RootListController

// 手动从 Root.plist 构建 specifier。
// 说明：本机/roothide 下 loadSpecifiersFromPlistName:target: 会返回 0（plist 字典
// 无法被系统方法转换成 PSSpecifier），因此这里手动遍历 PreferenceSpecifiers，
// 用 PSSpecifier 标准类方法逐个创建。
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

@end
