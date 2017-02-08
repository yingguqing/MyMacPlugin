//
//  SourceEditorCommand.m
//  MyPlugin
//
//  Created by 影孤清 on 16/9/19.
//  Copyright © 2016年 影孤清. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "CodeStatement.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {
    NSString *identifier = invocation.commandIdentifier;
    if ([identifier hasSuffix:@"CopyLineUp"]) {//向上复制选中代码
        [CodeStatement statementCopyLine:invocation isUp:true];
    } else if ([identifier hasSuffix:@"CopyLineDown"]) {//向下复制选中代码
        [CodeStatement statementCopyLine:invocation isUp:false];
    } else if ([identifier hasSuffix:@"DeleteLine"]) {//删除选中行代码
        [CodeStatement statementDeleteLine:invocation];
    } else if ([identifier hasSuffix:@"UppercaseString"]) {//选中代码大写
        [CodeStatement statementUppercaseString:invocation isUpper:true];
    } else if ([identifier hasSuffix:@"lowercaseString"]) {//选中代码小写
        [CodeStatement statementUppercaseString:invocation isUpper:false];
    } else if ([identifier hasSuffix:@"DocumentAdd"]) {//为方法添加注释说明
        [CodeStatement statementDocumentAdd:invocation];
    } else if ([identifier hasSuffix:@"Command"]) {// 使用//注释代码
        [CodeStatement statementCommand:invocation];
    } else if ([identifier hasSuffix:@"FormatCode"]) {// 格式化代码
        [CodeStatement statementFormatCode:invocation];
    } else if ([identifier hasSuffix:@"UpInsertEnter"]) {// 向上一行添加一个回车
        [CodeStatement statementInsertEnter:invocation isUp:true];
    } else if ([identifier hasSuffix:@"DownInsertEnter"]) {// 向下一行添加一个回车
        [CodeStatement statementInsertEnter:invocation isUp:false];
    } else if ([identifier hasSuffix:@"AddReleaseToDealloc"]) {// 添加一个释放到dealloc里
        [CodeStatement statementInsertReleaseToDealloc:invocation];
    }
    completionHandler(nil);
}

@end
