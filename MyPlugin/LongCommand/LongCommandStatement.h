//
//  LongCommandStatement.h
//  MyPlugin
//
//  Created by wurw on 2018/1/8.
//  Copyright © 2018年 影孤清. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface LongCommandStatement : NSObject
+ (void)longCommand:(XCSourceEditorCommandInvocation *_Nonnull)invocation;
@end
