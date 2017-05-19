//
//  Until.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/15.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import "Until.h"
#import <AppKit/AppKit.h>

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

@end
