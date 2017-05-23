//
//  JavaToObjectCStatement.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/19.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import "JavaToObjectCStatement.h"
#import "Until.h"

@implementation JavaToObjectCStatement

+ (void)javaToObjectCProperty:(XCSourceEditorCommandInvocation *_Nonnull)invocation {
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSArray *newArray = [invocation.buffer.lines subarrayWithRange:NSMakeRange(range.start.line, range.end.line - range.start.line + 1)];
    if (!newArray || newArray.count == 0) return;
    NSMutableDictionary<NSNumber *,NSString *> *reDic = [NSMutableDictionary dictionary];
    NSUInteger index = range.start.line;
    for (NSString *str in newArray.objectEnumerator) {
        NSString *nStr = [Until deleteFirstSpace:str];
        if (![Until isWhitespaceOrNewline:nStr]) {
            if ([nStr hasPrefix:@"private "]) {
                nStr = [nStr substringFromIndex:8];
            } else if ([nStr hasPrefix:@"public "]) {
                nStr = [nStr substringFromIndex:7];
            }
            NSRange range = [nStr rangeOfString:@" "];
            if (range.location != NSNotFound) {
                NSRange reRange = NSMakeRange(0, range.location+1);
                NSString *type = [nStr substringWithRange:reRange];
                NSString *header = nil;
                if ([@"int " isEqualToString:type] || [@"long " isEqualToString:type]) {
                    header = @"@property (nonatomic, assign) NSInteger ";
                } else if ([@"float " isEqualToString:type] || [@"double " isEqualToString:type]) {
                    header = @"@property (nonatomic, assign) CGFloat ";
                } else if ([@"String " isEqualToString:type]) {
                    header = @"@property (nonatomic, copy) NSString *";
                } else if ([@"bool " isEqualToString:type]) {
                    header = @"@property (nonatomic, assign) BOOL ";
                } else if ([@"long long " isEqualToString:type]) {
                    header = @"@property (nonatomic, assign) long long ";
                }
                NSString *insrtString = [nStr copy];
                if (!header) continue;
                insrtString = [insrtString stringByReplacingCharactersInRange:reRange withString:header];
                NSRange endRange = [nStr rangeOfString:@";"];
                if (endRange.location == NSNotFound) continue;
                NSRange nameRange = NSMakeRange(reRange.length, endRange.location - reRange.length);
                if (nameRange.location + nameRange.length > nStr.length) continue;
                NSString *name = [nStr substringWithRange:nameRange];
                if (!name || name.length == 0) continue;
                NSString *newName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (!name || name.length == 0) continue;
                NSString *n = [Until nameForNo_WithName:newName];
                if (n) {
                    NSString *saveName = [newName copy];
                    newName = n;
                    NSRange zxRange = [insrtString rangeOfString:@"//"];
                    NSString *s = nil;
                    if (zxRange.location == NSNotFound) {
                        zxRange = [insrtString rangeOfString:@";"];
                        s= [NSString stringWithFormat:@";//[%@]",saveName];
                    } else {
                        s = [NSString stringWithFormat:@"//[%@]",saveName];
                    }
                    insrtString = [insrtString stringByReplacingCharactersInRange:zxRange withString:s];
                    nameRange = [insrtString rangeOfString:saveName];
                    insrtString = [insrtString stringByReplacingCharactersInRange:nameRange withString:newName];
                }
                [reDic setObject:insrtString forKey:[NSNumber numberWithInteger:index]];
                index++;
            }
        }
    }
    if (reDic.count > 0) {
        [reDic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [invocation.buffer.lines replaceObjectAtIndex:[key integerValue] withObject:obj];
        }];
    }
}
@end
