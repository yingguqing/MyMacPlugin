//
//  LongCommandStatement.m
//  MyPlugin
//
//  Created by wurw on 2018/1/8.
//  Copyright © 2018年 影孤清. All rights reserved.
//

#import "LongCommandStatement.h"

@implementation LongCommandStatement
#pragma mark - 使用/**/注释代码
+ (void)longCommand:(XCSourceEditorCommandInvocation *_Nonnull)invocation {
    for (XCSourceTextRange *range in invocation.buffer.selections) {
        NSRange lineRange = NSMakeRange(range.start.line, range.end.line - range.start.line + 1);
        NSMutableArray *selectStrings = [NSMutableArray new];
        NSInteger startLine = range.start.line;
        NSInteger startColumn = range.start.column;
        NSInteger endLine = range.end.line;
        NSInteger endColumn = range.end.column;
        NSString *startString = [invocation.buffer.lines[startLine] substringToIndex:startColumn];
        NSString *endString = [invocation.buffer.lines[endLine] substringFromIndex:endColumn];
        if ([endString hasSuffix:@"\n"]) {//去掉最后一个回车
            endString = [endString substringToIndex:endString.length - 1];
        }
        if (startLine != endLine) {// 跨行选中
            NSString *string = [invocation.buffer.lines[startLine] substringFromIndex:startColumn];
            [selectStrings addObject:string];
            for (NSInteger i = startLine + 1; i < endLine; i++) {
                [selectStrings addObject:invocation.buffer.lines[i]];
            }
            string = [invocation.buffer.lines[endLine] substringToIndex:endColumn];
            [selectStrings addObject:string];
        } else {// 选中代码只在一行
            NSString *string = [invocation.buffer.lines[startLine] substringWithRange:NSMakeRange(startColumn, endColumn - startColumn)];
            if (string == nil) {
                string = @"";
            }
            [selectStrings addObject:string];
        }
        NSString *tempString = [selectStrings componentsJoinedByString:@""];
        if ([tempString hasPrefix:@"/*"] && [tempString hasSuffix:@"*/"]) {// 存在/**/
            tempString = [tempString substringWithRange:NSMakeRange(2, tempString.length - 4)];
        } else {
            tempString = [NSString stringWithFormat:@"/*%@*/",tempString];
        }
        tempString = [NSString stringWithFormat:@"%@%@%@",startString,tempString,endString];
        NSArray *array = [tempString componentsSeparatedByString:@"\n"];
        [invocation.buffer.lines replaceObjectsInRange:lineRange withObjectsFromArray:array];
        break;
    }
    XCSourceTextRange *selectionPosition = [[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(0, 0) end:XCSourceTextPositionMake(0, 0)];
    [invocation.buffer.selections removeAllObjects];
    [invocation.buffer.selections insertObject:selectionPosition atIndex:0];
}

+ (NSString *)spaceStringFromString:(NSString *)string isBack:(BOOL)isBack {
    if (string == nil || string.length == 0) {
        return @"";
    }
    NSMutableString *result = [NSMutableString string];
    NSUInteger startIndex = isBack ? string.length - 1 : 0;
    NSStringCompareOptions options = isBack ? NSBackwardsSearch : NSLiteralSearch;
    NSString *type = @"";
    while (true) {
        type = @" ";
        NSRange range = [string rangeOfString:type options:options];
        if (range.location == NSNotFound) {
            type = @"\n";
            range = [string rangeOfString:type options:options];
        }
        if (range.location == startIndex) {
            if (isBack) {
                startIndex -= range.length;
                [result insertString:type atIndex:0];
            }else {
                startIndex += range.length;
                [result appendString:type];
            }
        } else {
            break;
        }
    }
    return result;
}
@end
