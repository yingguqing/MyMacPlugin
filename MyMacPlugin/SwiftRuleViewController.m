//
//  SwiftRuleViewController.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2018/5/3.
//  Copyright © 2018年 影孤清. All rights reserved.
//

#import "SwiftRuleViewController.h"
#import "RuleViewModel.h"
#import "XcodePlugin-Swift.h"

@interface SwiftRuleViewController () <NSTableViewDelegate, NSTableViewDataSource>{
    NSMutableArray *result;
    NSUserDefaults *store;
}

@end

@implementation SwiftRuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    result = [NSMutableArray new];
    store = [[NSUserDefaults alloc] initWithSuiteName:RulesKey];
    NSDictionary *allRules = [store valueForKey:@"rules"];
    if (!allRules || (allRules.count == 0)) {
        allRules = [FormatRules defaultRules];        // 默认规则
        [store setObject:allRules forKey:@"rules"];
        [store synchronize];
    }
    NSArray *array = [allRules.allKeys sortedArrayUsingComparator:^NSComparisonResult (NSString *_Nonnull obj1, NSString *_Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
    for (NSString *name in array) {
        RuleViewModel *model = [[RuleViewModel alloc] initWithName:name isEnabled:[allRules[name] boolValue]];
        [result addObject:model];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return result.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return result[row];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [tableView makeViewWithIdentifier:@"RuleSelectionTableCellView" owner:self];
}

@end
