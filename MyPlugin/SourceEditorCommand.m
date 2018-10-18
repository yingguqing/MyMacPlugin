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
        return completionHandler(nil);
    }
    if ([@"yingguqing.CopyLineUp" isEqualToString:identifier]) {//向上复制选中代码
        [CodeStatement statementCopyLine:invocation isUp:true];
    } else if ([@"yingguqing.CopyLineDown" isEqualToString:identifier]) {//向下复制选中代码
        [CodeStatement statementCopyLine:invocation isUp:false];
    } else if ([@"yingguqing.DeleteLine" isEqualToString:identifier]) {//删除选中行代码
        [CodeStatement statementDeleteLine:invocation];
    } else if ([@"yingguqing.UppercaseString" isEqualToString:identifier]) {//选中代码大写
        [CodeStatement statementUppercaseString:invocation isUpper:true];
    } else if ([@"yingguqing.lowercaseString" isEqualToString:identifier]) {//选中代码小写
        [CodeStatement statementUppercaseString:invocation isUpper:false];
    } else if ([@"yingguqing.DocumentAdd" isEqualToString:identifier]) {//为方法添加注释说明
        [CodeStatement statementDocumentAdd:invocation];
    } else if ([@"yingguqing.Command" isEqualToString:identifier]) {// 使用//注释代码
        [CodeStatement statementCommand:invocation];
    } else if ([@"yingguqing.FormatCode" isEqualToString:identifier]) {// 格式化代码
        if (!isSwiftSource(invocation)) {//OC代码格式化
            [CodeStatement statementFormatCode:invocation];
        } else {//swift代码格式化
            [FormatSwiftCodeStatement formatSwiftCodeStatementWithInvocation:invocation completionHandler:completionHandler];
        }
    } else if ([@"yingguqing.UpInsertEnter" isEqualToString:identifier]) {// 向上一行添加一个回车
        [CodeStatement statementInsertEnter:invocation isUp:true];
    } else if ([@"yingguqing.DownInsertEnter" isEqualToString:identifier]) {// 向下一行添加一个回车
        [CodeStatement statementInsertEnter:invocation isUp:false];
    } else if ([@"yingguqing.AddReleaseToDealloc" isEqualToString:identifier]) {// 添加一个释放到dealloc里
        [CodeStatement statementInsertReleaseToDealloc:invocation];
    } else if ([@"yingguqing.JsonToProperty" isEqualToString:identifier]) {// 将Json转成h文件里的属性
        [JsonToPropertyStatement statementJsonToProperty:invocation];
    } else if ([@"yingguqing.UserInitWithJson" isEqualToString:identifier]) {// 自动生成创建和解析方法
        [InitWithJsonStatement statementInitWithJson:invocation];
    } else if ([@"yingguqing.import" isEqualToString:identifier]) {// 导入头文件
        [ImportStatement execute:invocation];
    } else if ([@"yingguqing.JavaToObjectC" isEqualToString:identifier]) {// Java属性转成OC属性
        [JavaToObjectCStatement javaToObjectCProperty:invocation];
    } else if ([@"yingguqing.LongCommand" isEqualToString:identifier]) {// /**/注释代码
        [LongCommandStatement longCommand:invocation];
    }
    completionHandler(nil);
}


@end
