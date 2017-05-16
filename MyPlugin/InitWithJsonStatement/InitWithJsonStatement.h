//
//  InitWithJsonStatement.h
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/15.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface InitWithJsonStatement : NSObject
+ (void)statementInitWithJson:(XCSourceEditorCommandInvocation *_Nonnull)invocation;
@end
