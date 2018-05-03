//
//  SourceEditorCommand.m
//  MyPlugin
//
//  Created by 影孤清 on 16/9/19.
//  Copyright © 2016年 影孤清. All rights reserved.
//


#import "SourceEditorCommand.h"
#import "CodeStatement.h"
#import "JsonToPropertyStatement.h"
#import "Until.h"
#import "InitWithJsonStatement.h"
#import "ImportStatement.h"
#import "JavaToObjectCStatement.h"
#import "MyPlugin-Swift.h"
#import "LongCommandStatement.h"

@interface SourceEditorCommand ()
@property (nonatomic, strong) XCSourceTextBuffer *buffer;
@property (nonatomic, copy) void (^completionHandler)(NSError *_Nullable nilOrError);
@end

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {
    NSString *identifier = invocation.commandIdentifier;
    if (identifier == nil || identifier.length == 0) {
        printf("identifier为空");
    }
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
        // swift代码格式化
        if ([@[@"public.swift-source", @"com.apple.dt.playground"] containsObject:invocation.buffer.contentUTI]) {
            [FormatSwiftCodeStatement formatSwiftCodeStatementWithInvocation:invocation completionHandler:completionHandler];
        } else {//OC代码格式化
            [CodeStatement statementFormatCode:invocation];
        }
    } else if ([identifier hasSuffix:@"UpInsertEnter"]) {// 向上一行添加一个回车
        [CodeStatement statementInsertEnter:invocation isUp:true];
    } else if ([identifier hasSuffix:@"DownInsertEnter"]) {// 向下一行添加一个回车
        [CodeStatement statementInsertEnter:invocation isUp:false];
    } else if ([identifier hasSuffix:@"AddReleaseToDealloc"]) {// 添加一个释放到dealloc里
        [CodeStatement statementInsertReleaseToDealloc:invocation];
    } else if ([identifier hasSuffix:@"JsonToProperty"]) {// 将Json转成h文件里的属性
        [JsonToPropertyStatement statementJsonToProperty:invocation];
    } else if ([identifier hasSuffix:@"UserInitWithJson"]) {// 自动生成创建和解析方法
        [InitWithJsonStatement statementInitWithJson:invocation];
    } else if ([identifier hasSuffix:@"import"]) {// 导入头文件
        [ImportStatement execute:invocation];
    } else if ([identifier hasSuffix:@"JavaToObjectC"]) {// Java属性转成OC属性
        [JavaToObjectCStatement javaToObjectCProperty:invocation];
    } else if ([identifier hasSuffix:@"JavaToObjectC"]) {// /**/注释代码
        [LongCommandStatement longCommand:invocation];
    }
    completionHandler(nil);
}


@end
