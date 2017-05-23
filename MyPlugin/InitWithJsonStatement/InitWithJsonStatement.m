//
//  InitWithJsonStatement.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/15.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import "InitWithJsonStatement.h"
#import "Until.h"

@implementation InitWithJsonStatement

+ (void)statementInitWithJson:(XCSourceEditorCommandInvocation *_Nonnull)invocation {
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSRange subRange = NSMakeRange(range.start.line, range.end.line - range.start.line + 1);
    NSArray *a = [invocation.buffer.lines subarrayWithRange:subRange];
    if (!a || a.count == 0) return;
    NSMutableDictionary *nameDic = [NSMutableDictionary dictionary];
    for (NSString *s in a.objectEnumerator) {
        if ([s rangeOfString:@"@property"].location != NSNotFound) {
            NSUInteger location = [s rangeOfString:@")"].location+1;
            NSRange range = NSMakeRange(location, [s rangeOfString:@";"].location - location);
            NSString *nStr = [s substringWithRange:range];
            NSString *str = [self clearWhitespace:nStr];
            NSString *type = nil;
            NSString *name = nil;
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
            NSString *parserName = nil;
            NSRange pRage = [s rangeOfString:@"//["];
            if (pRage.location != NSNotFound) {
                NSRange endRage = [s rangeOfString:@"]"];
                if (endRage.location != NSNotFound && endRage.location > (pRage.location + pRage.length)) {
                    NSRange range = NSMakeRange(pRage.location + pRage.length, endRage.location - (pRage.location + pRage.length));
                    parserName = [s substringWithRange:range];
                }
            }
            if (type && name && name.length > 0 && type.length > 0) {
                NSString *key = [NSString stringWithFormat:@"%@#%@",name,type];
                if (parserName && parserName.length > 0) {
                    [nameDic setObject:parserName forKey:key];
                } else {
                    [nameDic setObject:[NSNumber numberWithBool:false] forKey:key];
                }
            }
        }
    }
    
    NSMutableString *initString = [NSMutableString stringWithString:@"- (id)initWithJson:(NSDictionary *)json {\n"];
    [initString appendString:@"    self = [super init];\n"];
    [initString appendString:@"    if (self && json) {\n"];
    if (nameDic.count > 0) {
        for (NSString *str in nameDic.keyEnumerator) {
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
                    NSString *parserName = name;
                    if ([nameDic[str] isKindOfClass:[NSString class]]) {
                        parserName = (NSString *)nameDic[str];
                    }
                    [initString appendFormat:@"        self.%@ = [self %@:@\"%@\" json:json];\n",name,parserString,parserName];
                }
            }
        }        
    }
    [initString appendString:@"    }\n    return self;\n}\n\n\n"];
    NSInteger index = [Until findStringIndex:@"@end" endString:nil findRang:NSMakeRange(range.start.line, invocation.buffer.lines.count - range.start.line) allString:invocation.buffer.lines isOrder:true];
    if (index >= 0) {
        [invocation.buffer.lines insertObject:initString atIndex:index];
    } else {
        [invocation.buffer.lines addObject:initString];
    }
}

+ (NSString *)clearWhitespace:(NSString *)str {
    if (str) {
        return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return str;
}

@end
