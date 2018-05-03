//
//  LongCommandStatement.m
//  MyPlugin
//
//  Created by wurw on 2018/1/8.
//  Copyright © 2018年 影孤清. All rights reserved.
//

#import "LongCommandStatement.h"

@implementation LongCommandStatement
+ (void)longCommand:(XCSourceEditorCommandInvocation *_Nonnull)invocation {
    for (XCSourceTextRange *range in invocation.buffer.selections) {
        NSRange lineRange = NSMakeRange(range.start.line, range.end.line - range.start.line + 1);
        NSArray *newArray = [invocation.buffer.lines subarrayWithRange:lineRange];
        if (!newArray || newArray.count == 0) continue;
        NSString *oString = [newArray componentsJoinedByString:@"\n"];
        NSString *hSpaceString = [self spaceStringFromString:oString isBack:false];
        NSString *bSpaceString = [self spaceStringFromString:oString isBack:true];
        NSString *string = [oString  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([string hasPrefix:@"/*"] && [string hasSuffix:@"*/"]) {
            string = [string substringWithRange:NSMakeRange(2, string.length - 2)];
        } else if ([string hasPrefix:@"/*"]) {
            hSpaceString = @"";
            string = [NSString stringWithFormat:@"%@\n*/",string];
        } else if ([string hasSuffix:@"*/"]) {
            bSpaceString = @"";
            string = [NSString stringWithFormat:@"/*\n%@",string];
        } else {
            string = [NSString stringWithFormat:@"/*\n%@\n*/",string];
        }
        oString = [NSString stringWithFormat:@"%@%@%@",hSpaceString,string,bSpaceString];
        [invocation.buffer.lines replaceObjectsInRange:lineRange withObjectsFromArray:@[oString]];
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
