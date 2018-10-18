//
//  Until.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/15.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import "Until.h"
#import <AppKit/AppKit.h>
#import <XcodeKit/XcodeKit.h>

@implementation Until

+ (void)showMsg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = msg;
        [alert addButtonWithTitle:@"OK"];
        alert.window.level = NSStatusWindowLevel;
        [alert.window makeKeyAndOrderFront:alert.window];
        if ([alert runModal] == NSAlertFirstButtonReturn) {}
    });
}

+ (BOOL)isWhitespaceOrNewline:(NSString *)str {
    NSString *string = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return string == nil || string.length == 0;
}

#pragma mark - 删除文字前面的空格
+ (NSString *)deleteFirstSpace:(NSString *)oldString {
    if ((oldString == nil) || (oldString.length == 0)) {
        return @"";
    }
    NSString *newString = oldString;
    
    while (newString.length > 0) {
        if ([newString hasPrefix:@" "]) {
            if (newString.length > 1) {
                newString = [newString substringFromIndex:1];
            } else {
                newString = @"";
            }
        } else {
            break;
        }
    }
    
    return newString;
}

+ (NSString *)nameForNo_WithName:(NSString *)name {
    NSRange _Range = [name rangeOfString:@"_"];
    if (_Range.location != NSNotFound) {
        while (true) {
            NSRange range = NSMakeRange(_Range.location, 2);
            NSString *nextChar = [name substringWithRange:NSMakeRange(_Range.location + 1, 1)];
            if (!nextChar || nextChar.length == 0) break;
            nextChar = [nextChar uppercaseString];
            name = [name stringByReplacingCharactersInRange:range withString:nextChar];
            _Range = [name rangeOfString:@"_"];
            if (_Range.location == NSNotFound) {
                break;
            }
        }
        return name;
    }
    return nil;
}

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
+ (NSInteger)findStringIndex:(NSString *)searchString endString:(NSString *)endString findRang:(NSRange)range allString:(NSArray<NSString *> *)allString isOrder:(BOOL)isOrder {
    if (!searchString || searchString.length == 0 || !allString || allString.count == 0) return -1;
    NSUInteger count = allString.count;
    if (count > range.location + range.length) count = range.location + range.length;
    if (isOrder) {
        for (NSUInteger i = range.location; i < count; i++) {
            NSString *string = allString[i];
            if ([string hasPrefix:searchString]) return i;
            if (endString && endString.length > 0 && [string hasPrefix:endString]) return count + i;
        }
    } else {
        for (NSInteger i = range.location; i >= 0; i--) {
            NSString *string = allString[i];
            if ([string hasPrefix:searchString]) return i;
            if (endString && endString.length > 0 && [string hasPrefix:endString]) return count + i;
        }
    }
    return -1;
}

BOOL isOCSource(XCSourceEditorCommandInvocation *invocation) {
    static NSArray *OCSourceArray = nil;
    OCSourceArray = @[@"public.objective-c-source"];
    if (invocation) {
        return [OCSourceArray containsObject:invocation.buffer.contentUTI];
    }
    return false;
}

BOOL isSwiftSource(XCSourceEditorCommandInvocation *invocation) {
    NSLog(@"%@",invocation.buffer.contentUTI);
    static NSArray *SwiftSourceArray = nil;
    SwiftSourceArray = @[@"public.swift-source", @"com.apple.dt.playground"];
    if (invocation) {
        return [SwiftSourceArray containsObject:invocation.buffer.contentUTI];
    }
    return false;
}

@end

