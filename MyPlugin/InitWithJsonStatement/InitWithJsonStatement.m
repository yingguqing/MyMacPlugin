//
//  InitWithJsonStatement.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/15.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import "InitWithJsonStatement.h"

@implementation InitWithJsonStatement

+ (void)statementInitWithJson:(XCSourceEditorCommandInvocation *_Nonnull)invocation {
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSMutableString *allString = [NSMutableString string];
    for (NSInteger i = range.start.line; i <= range.end.line; i++) {
        if (i < invocation.buffer.lines.count) {
            [allString appendString:invocation.buffer.lines[i]];
        }
    }
    if (!allString || allString.length == 0) return;
    NSArray *a = [allString componentsSeparatedByString:@";\n"];
    if (!a || a.count == 0) return;
    NSMutableArray *valueArr = [NSMutableArray array];
    for (NSString *str in a.objectEnumerator) {
        if ([str rangeOfString:@"@property"].location != NSNotFound) {
            NSString *nStr = [str substringFromIndex:[str rangeOfString:@")"].location+1];
            [valueArr addObject:[self clearWhitespace:nStr]];
        }
    }
    if (valueArr.count == 0) return;
    NSMutableArray *nameTypeArr = [NSMutableArray array];
    NSString *type = nil;
    NSString *name = nil;
    for (NSString *str in valueArr.objectEnumerator) {
        if ([str rangeOfString:@"*"].location != NSNotFound) {
            NSArray *a = [str componentsSeparatedByString:@"*"];
            if (a && a.count == 2) {
                type = [self clearWhitespace:a[0]];
                name = [self clearWhitespace:a[1]];
            }
        } else {
            NSRange range = [str  rangeOfString:@" " options:NSBackwardsSearch];
            type = [self clearWhitespace:[str substringToIndex:range.location]];
            name = [self clearWhitespace:[str substringFromIndex:range.location + 1]];
        }
        if (type && name && name.length > 0 && type.length > 0) {
            [nameTypeArr addObject:[NSString stringWithFormat:@"%@#%@",name,type]];
        }
        type = nil;
        name = nil;
    }
    NSMutableString *initString = [NSMutableString stringWithString:@"- (id)initWithJson:(NSDictionary *)json {\n"];
    [initString appendString:@"    self = [super init];\n"];
    [initString appendString:@"    if (self && json) {\n"];
    if (nameTypeArr.count > 0) {
        for (NSString *str in nameTypeArr.objectEnumerator) {
            NSArray *a = [str componentsSeparatedByString:@"#"];
            if (a && a.count == 2) {
                NSString *name = a[0];
                NSString *type = a[1];
                NSString *parserString = nil;
                if ([@"NSUInteger" isEqualToString:type] || [@"NSInteger" isEqualToString:type]) {
                    parserString = @"integerParser";
                } else if ([@"int" isEqualToString:type]) {
                    parserString = @"intParser";
                } else if ([@"float" isEqualToString:type]) {
                    parserString = @"floatParser";
                } else if ([@"CGFloat" isEqualToString:type] || [@"double" isEqualToString:type]) {
                    parserString = @"doubleParser";
                } else if ([@"NSString" isEqualToString:type]) {
                    parserString = @"stringParser";
                } else if ([@"BOOL" isEqualToString:type]) {
                    parserString = @"boolParser";
                } else if ([@"long" isEqualToString:type]) {
                    parserString = @"longParser";
                } else if ([@"long long" isEqualToString:type]) {
                    parserString = @"longlongParser";
                }
                if (parserString && parserString.length > 0) {
                    [initString appendFormat:@"        self.%@ = [self %@:@\"%@\" json:json];\n",name,parserString,name];
                }
            }
        }        
    }
    [initString appendString:@"    }\n    return self;\n}\n\n\n"];
    [invocation.buffer.lines addObject:initString];
}

+ (NSString *)clearWhitespace:(NSString *)str {
    if (str) {
        return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return str;
}

@end
