//
//  RuleViewModel.h
//  MyMacPlugin
//
//  Created by 影孤清 on 2018/5/3.
//  Copyright © 2018年 影孤清. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const RulesKey = @"com.charcoaldesign.SwiftFormat";

@interface RuleViewModel : NSObject
@property (assign, nonatomic) BOOL isEnabled;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL isAutoSave;
@property (assign, nonatomic) NSInteger index;

- (instancetype)initWithIndex:(NSInteger)index json:(NSDictionary *)json;
- (instancetype)initWithName:(NSString *)name isEnabled:(BOOL)isEnabled;
@end
