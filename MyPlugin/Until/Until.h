//
//  Until.h
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/15.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCSourceEditorCommandInvocation;
@interface Until : NSObject
+ (void)showMsg:(NSString *)msg;
+ (BOOL)isWhitespaceOrNewline:(NSString *)str;
+ (NSString *)deleteFirstSpace:(NSString *)oldString;
+ (NSString *)nameForNo_WithName:(NSString *)name;
/**
 *  @brief  查找文字所在行
 *
 *  @param searchString 查找文字
 *  @param endString    结束文字(可以为空)
 *  @param range        查找范围
 *  @param allString    所有文字(NSArray<NSString *>类型)
 *  @param isOrder      true为顺序查找,false为逆序查找
 *
 *  @return  目标文字所在行,不存在是返回-1,如果在范围内遇到结束文字,文字所以行就加上总行数
 */
+ (NSInteger)findStringIndex:(NSString *)searchString endString:(NSString *)endString findRang:(NSRange)range allString:(NSArray<NSString *> *)allString isOrder:(BOOL)isOrder;

BOOL isOCSource(XCSourceEditorCommandInvocation *invocation);
BOOL isSwiftSource(XCSourceEditorCommandInvocation *invocation);
@end

