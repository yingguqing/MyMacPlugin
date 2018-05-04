//
//  KeyBindingsInserter.h
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/17.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyBindingsInserter : NSObject 
@property (strong) NSString *path;
@property (strong, nonatomic) NSArray *KeyBindArray;
- (instancetype)initWithPath:(NSString *)path;
- (void)insertBindings;
- (void)deleteAllOtherKeyWithPath:(NSString *)path;
@end
