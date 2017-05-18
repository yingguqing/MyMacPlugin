//
//  ImportStatement.h
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/18.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface ImportStatement : NSObject
+ (void)execute:(XCSourceEditorCommandInvocation *_Nonnull)invocation;
@end
