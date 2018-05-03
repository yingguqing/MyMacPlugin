//
//  RuleViewModel.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2018/5/3.
//  Copyright © 2018年 影孤清. All rights reserved.
//

#import "RuleViewModel.h"

@implementation RuleViewModel

- (instancetype)initWithIndex:(NSInteger)index json:(NSDictionary *)json {
    self = [super init];
    if (self) {
        _index = index;
        _name = [NSString stringWithFormat:@"%@ %@",json[@"Title"],json[@"ShowShortcut"]];
        _isEnabled = [json[@"Enable"] boolValue];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name isEnabled:(BOOL)isEnabled {
    self = [super init];
    if (self) {
        _name = name;
        _isEnabled = isEnabled;
        _isAutoSave = true;
    }
    return self;
}

- (void)setIsEnabled:(BOOL)isEnabled {
    _isEnabled = isEnabled;
    if (_isAutoSave) {
        [self saveRules];
    }
}

- (void)saveRules {
    NSUserDefaults *store = [[NSUserDefaults alloc] initWithSuiteName:RulesKey];
    NSMutableDictionary *rules = [[store valueForKey:@"rules"] mutableCopy];
    id obj = rules[_name];
    if (obj) {
        rules[_name] = @(_isEnabled);
    } else {
        [rules setObject:@(_isEnabled) forKey:_name];
    }
    [store setObject:rules forKey:@"rules"];
    [store synchronize];
}

@end
