//
//  JavaToObjectCStatement.h
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/19.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface JavaToObjectCStatement : NSObject
+ (void)javaToObjectCProperty:(XCSourceEditorCommandInvocation *_Nonnull)invocation;
@end
