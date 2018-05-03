//
//  ViewController.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/17.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import "ViewController.h"
#import "KeyBindingsInserter.h"
#import "RuleViewModel.h"

@interface ViewController ()<NSTableViewDelegate,NSTableViewDataSource> {
	KeyBindingsInserter *keyBinding;
    NSMutableArray *result;
}

@end

#define KeyBindingsPath @"/Library/Developer/Xcode/UserData/KeyBindings/yingguqing.idekeybindings"
//#define KeyBindingsPath @"/Desktop/yingguqing.idekeybindings"

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	NSString *keyBindingsPath = [NSHomeDirectory() stringByAppendingPathComponent:KeyBindingsPath];
	keyBinding = [[KeyBindingsInserter alloc] initWithPath:keyBindingsPath];
    NSInteger index = 0;
    result = [NSMutableArray new];
    // 生成RuleModel
    for (NSDictionary *json in keyBinding.KeyBindArray) {
        RuleViewModel *model = [[RuleViewModel alloc] initWithIndex:index json:json];
        [result addObject:model];
        index++;
    }
}

- (IBAction)installKeyBindings:(NSButton *)sender {
    NSMutableArray *array = [keyBinding.KeyBindArray mutableCopy];
    for (RuleViewModel *model in result) {
        NSMutableDictionary *dic = [array[model.index] mutableCopy];
        // 设置是否绑定快捷键
        dic[@"Enable"] = @(model.isEnabled);
        [array replaceObjectAtIndex:model.index withObject:dic];
    }
    keyBinding.KeyBindArray = array;
	[keyBinding insertBindings];
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
