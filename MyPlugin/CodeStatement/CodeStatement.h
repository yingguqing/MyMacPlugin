//
//  CodeStatement.h
//  TextPlugin
//
//  Created by 影孤清 on 16/9/19.
//  Copyright © 2016年 影孤清. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface CodeStatement : NSObject
/**
 *  @brief  为方法添加文字注释
 *
 *  @param invocation <#invocation description#>
 *
 */
+ (void)statementDocumentAdd:(XCSourceEditorCommandInvocation *)invocation;

/**
 *  @brief  使用//注释代码
 *
 *  @param invocation <#invocation description#>
 *
 */
+ (void)statementCommand:(XCSourceEditorCommandInvocation *)invocation;

/**
 * 复制一行代码
 *
 * @param invocation <#invocation description#>
 */
+ (void)statementCopyLine:(XCSourceEditorCommandInvocation *)invocation isUp:(BOOL)isUp;

/**
 *  @brief  删除选中行代码
 *
 *  @param invocation <#invocation description#>
 *
 */
+ (void)statementDeleteLine:(XCSourceEditorCommandInvocation *)invocation;

/**
 *  @brief  对选中代码进行大小写
 *
 *  @param invocation <#invocation description#>
 *  @param isUpper    <#isUpper description#>
 *
 */
+ (void)statementUppercaseString:(XCSourceEditorCommandInvocation *)invocation isUpper:(BOOL)isUpper;

/**
 *  @brief  格式化代码
 *
 *  @param invocation <#invocation description#>
 */ 
+ (void)statementFormatCode:(XCSourceEditorCommandInvocation *)invocation;

/**
 *  @brief  添加一行回车
 *
 *  @param invocation <#invocation description#>
 *  @param isUp    <#isUpper description#>
 *
 */ 
+ (void)statementInsertEnter:(XCSourceEditorCommandInvocation *)invocation isUp:(BOOL)isUp;

/**
 *  @brief  添加一个变量的释放到dealloc
 *
 *  @param invocation <#invocation description#> 
 *
 */
+ (void)statementInsertReleaseToDealloc:(XCSourceEditorCommandInvocation *)invocation;
@end
