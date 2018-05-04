//
//  CodeStatement.m
//  TextPlugin
//
//  Created by 影孤清 on 16/9/19.
//  Copyright © 2016年 影孤清. All rights reserved.
//

#import "CodeStatement.h"
#import "Until.h"

@implementation CodeStatement

#pragma mark - 使用// 注释代码
+ (void)statementCommand:(XCSourceEditorCommandInvocation *)invocation {
	for (XCSourceTextRange *range in invocation.buffer.selections) {
		NSInteger startLine = range.start.line;
		NSInteger endLine = range.end.line;

		BOOL isAdd = NO;

		for (NSInteger index = startLine; index <= endLine; index++) {
			NSString *line = [Until deleteFirstSpace:invocation.buffer.lines[index]];

			// 去掉了顶头的所有空格
			if ((line == nil) || (line.length == 0) || ![line hasPrefix:@"//"]) {
				isAdd = YES;
				break;
			}
		}

		for (NSInteger index = startLine; index <= endLine; index++) {
			NSString *line = invocation.buffer.lines[index];

			if (line == nil) {
				line = @"";
			}
			NSMutableString *stringNew = [[NSMutableString alloc] initWithString:line];

			if (isAdd) {
				// 添加注释
                NSInteger index = 0;
                if (line && line.length > 0) {
                    NSString *newString = line;
                    while (newString.length > 0) {
                        if ([newString hasPrefix:@" "]) {
                            if (newString.length > 1) {
                                index++;
                                newString = [newString substringFromIndex:1];
                            } else {
                                break;
                            }
                        } else {
                            break;
                        }
                    }
                }
                [stringNew insertString:@"//" atIndex:index];
                range.start = XCSourceTextPositionMake(range.start.line, range.start.column+2);
                range.end = XCSourceTextPositionMake(range.start.line, range.start.column+2);
			} else {
				//删除注释
                
				NSRange range = [stringNew rangeOfString:@"//"];
				[stringNew replaceCharactersInRange:range withString:@""];
			}
			[invocation.buffer.lines replaceObjectAtIndex:index withObject:stringNew];
		}
	}
}

#pragma mark - 为方法添加文字注释
+ (void)statementDocumentAdd:(XCSourceEditorCommandInvocation *)invocation {
    NSMutableString *stringDuel = [[NSMutableString alloc] init];
    NSInteger insertLine = -1;
    for (XCSourceTextRange *range in invocation.buffer.selections) {
        NSInteger startLine = range.start.line;
        NSInteger linecount = [invocation.buffer.lines count];
        BOOL valid = NO;
        BOOL needUp = YES;//需要向上检索
        for (NSInteger index = startLine; index < linecount ;index ++){
            NSString *line = [Until deleteFirstSpace:invocation.buffer.lines[index]];
            if (line != nil && line.length > 0 && ![line isEqualToString:@"\n"]) {
                //方法名称结束
                valid = ([line rangeOfString:@"{"].length > 0 || [line rangeOfString:@";"].length > 0);
                if (stringDuel.length == 0) {
                    [stringDuel appendString:line];
                } else {
                    [stringDuel appendFormat:@" %@",line];
                }
                
                if (needUp) {
                    if ([line hasPrefix:@"-"] || [line hasPrefix:@"+"]) {
                        //方法的开始
                        needUp = NO;
                        insertLine = index;
                    }
                }
                if (valid) break;//已经检测到结尾
            }
        }
        
        if (!valid) return;
        if (needUp){
            if (startLine > 0) {//没有找到方法的开始位置
                for (NSInteger index = startLine - 1 ; index > 0 ;index --){
                    NSString *line = [Until deleteFirstSpace:invocation.buffer.lines[index]];
                    if (line != nil && line.length > 0) {
                        if ([line rangeOfString:@"{"].length > 0 || [line rangeOfString:@";"].length > 0) {
                            //方法名称结束
                            valid = NO;
                            break;
                        }
                        if (stringDuel.length == 0) {
                            [stringDuel insertString:line atIndex:0];
                        } else {
                            [stringDuel insertString:[NSString stringWithFormat:@"%@ ",line] atIndex:0];
                        }
                        if ([line hasPrefix:@"-"] || [line hasPrefix:@"+"]) {//方法的开始
                            needUp = NO;
                            insertLine = index;
                            break;
                        }
                    }
                }
            } else {
                return;
            }
        }
        
        if (needUp || !valid) {
            return;
        }
    }
    
    NSMutableArray *insertStrings = [[NSMutableArray alloc] init];
    [insertStrings addObject:@"/**\n"];
    [insertStrings addObject:@" *  @brief  <#brief#>\n"];
    [insertStrings addObject:@" *\n"];
    
    BOOL returnNA = NO;
    
    NSArray *cut = [stringDuel componentsSeparatedByString:@":"];
    NSInteger cutCount = [cut count];
    if (cut != nil && cutCount > 0) {
        NSString *stringReturn = [cut firstObject];
        {
            NSArray *array_return = [self regularFinder:@"\\(.*\\)" string:stringReturn];
            if ([array_return count]) {
                for (id XX in array_return) {
                    NSRange resultRange = [XX rangeAtIndex:0];
                    NSString *result = [stringReturn substringWithRange:resultRange];
                    if ([result rangeOfString:@"void"].length > 0) {
                        returnNA = YES;
                    }
                    break;
                }
            }
        }
        
        BOOL parameter = NO;
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        NSInteger lengthMax = 0;
        for (int i = 1; i < cutCount; i++) {
            NSString *stringParameter = [cut objectAtIndex:i];
            NSRange range = [stringParameter rangeOfString:@")"];
            if (range.location != NSNotFound) {
                NSInteger start = -1;
                NSInteger end = -1;
                for (NSInteger j = range.location + 1; j < stringParameter.length; j++) {
                    char sub = [stringParameter characterAtIndex:j];
                    if (sub == ' ' || sub == ';') {
                        if (start == -1) {
                            continue;
                        } else {
                            end = j;
                            break;
                        }
                    } else {
                        if (start == -1) {
                            start = j;
                        }
                    }
                }
                if (start != -1 && end != -1) {
                    range.location = start;
                    range.length = end - start;
                    NSString *parameterName = [stringParameter substringWithRange:range];
                    parameterName = [parameterName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    if (parameterName != nil && parameterName.length > 0) {
                        if (range.length >= lengthMax) {
                            lengthMax = range.length;
                        }
                        [parameters addObject:parameterName];
                    }
                }
            }
        }
        
        NSInteger len = @" *  @param ".length + lengthMax + 1;
        for (NSInteger index = 0; index < [parameters count]; index ++) {
            NSString *parameterName = [parameters objectAtIndex:index];
            NSMutableString *strtup = [[NSMutableString alloc] init];
            [strtup appendFormat:@" *  @param %@ ",parameterName];
            while (strtup.length < len) {
                [strtup appendString:@" "];
            }
            
            [strtup appendFormat:@" <#%@ description#> \n",parameterName];
            [insertStrings addObject:strtup];
            parameter = YES;
        }
        if (parameter) {
            [insertStrings addObject:@" *\n"];
        }
    }
    if (returnNA) {
//        [insertStrings addObject:@" *  @return \n"];
    } else {
        [insertStrings addObject:@" *  @return <#return description#> \n"];
    }
    [insertStrings addObject:@" */ \n"];
    
    for (int i = 0 ; i < [insertStrings count]; i++){
        NSString *ins = [insertStrings objectAtIndex:i];
        [invocation.buffer.lines insertObject:ins atIndex:insertLine + i];
    }
}

#pragma mark - 检测正则表达式
+ (NSArray *)regularFinder:(NSString *)regular string:(NSString *)str {
	NSError *error_finder;
	// 这是检测正则表达式
	NSRegularExpression *regex_finder = [NSRegularExpression regularExpressionWithPattern:regular options:0 error:&error_finder];

	if (regex_finder != nil) {
		NSArray *array_finder = [regex_finder matchesInString:str options:0 range:NSMakeRange(0, [str length])];
		return array_finder;
	}
	return nil;
}

#pragma mark - 复制一行代码
+ (void)statementCopyLine:(XCSourceEditorCommandInvocation *)invocation isUp:(BOOL)isUp {
	NSInteger insertLine = -1;
    NSMutableArray *select = [NSMutableArray array];
	for (XCSourceTextRange *range in invocation.buffer.selections) {
		NSMutableString *stringDuel = [[NSMutableString alloc] init];
		NSInteger startLine = range.start.line;
		NSInteger endLine = range.end.line;
        if (range.end.column == 0) {
            endLine--;
        }
        if (endLine < startLine) {
            return;
        }
        NSInteger length = endLine - startLine;
		if (insertLine < 0) {
			insertLine = isUp ? startLine : endLine + 1;
		} else {
			insertLine += endLine - startLine + 1;
		}

		for (NSInteger i = startLine; i <= endLine; i++) {
			[stringDuel appendString:invocation.buffer.lines[i]];
		}

        [invocation.buffer.lines insertObject:stringDuel atIndex:insertLine];
        XCSourceTextRange *newRange = [[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(insertLine, range.start.column) end:XCSourceTextPositionMake(insertLine + length, range.end.column)];
        [select addObject:newRange];
    }
    [invocation.buffer.selections removeAllObjects];
    [invocation.buffer.selections addObjectsFromArray:select];
}

#pragma mark - 删除选中行代码
+ (void)statementDeleteLine:(XCSourceEditorCommandInvocation *)invocation {
	NSInteger newLine = -1;
	for (XCSourceTextRange *range in invocation.buffer.selections) {
		NSInteger startLine = range.start.line;
		NSInteger endLine = range.end.line;
		if (newLine == -1) newLine = startLine;//标记选中位置,用于最后光标位置

		NSInteger length = endLine + 1 - startLine;
		NSRange deleteRange = NSMakeRange(range.start.line, length);
		[invocation.buffer.lines removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:deleteRange]];
	}
	newLine = MIN(newLine, invocation.buffer.lines.count - 1);
	[invocation.buffer.selections removeAllObjects];
	XCSourceTextRange *newRange = [[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(newLine, 0) end:XCSourceTextPositionMake(newLine, 0)];
	[invocation.buffer.selections addObject:newRange];
}

#pragma mark - 对选中代码进行大小写
+ (void)statementUppercaseString:(XCSourceEditorCommandInvocation *)invocation isUpper:(BOOL)isUpper {
	for (XCSourceTextRange *range in invocation.buffer.selections) {
		NSInteger startLine = range.start.line;
		NSInteger endLine = range.end.line;
		NSInteger startColumn = range.start.column;
		NSInteger endColumn = range.end.column;
		if ((startLine == endLine) && (startColumn == endColumn)) continue;

		for (NSInteger i = startLine; i <= endLine; i++) {
			NSString *string = invocation.buffer.lines[i];
			if (!string || (string.length == 0)) continue;
            NSRange selectRange = NSMakeRange(startColumn, endColumn - startColumn);
            //选中文字
			NSString *selectString = [string substringWithRange:selectRange];
            //对选中文字进行大小写
			selectString = isUpper ?[selectString uppercaseString] :[selectString lowercaseString];
            string = [string stringByReplacingCharactersInRange:selectRange withString:selectString];
			[invocation.buffer.lines replaceObjectAtIndex:i withObject:string];
		}
	}
}

#pragma mark - 格式化代码
+ (void)statementFormatCode:(XCSourceEditorCommandInvocation *)invocation {
	NSInteger newLine = -1;

	for (XCSourceTextRange *range in invocation.buffer.selections) {
		NSMutableString *selectString = [NSMutableString string];
		NSInteger startLine = range.start.line;
		NSInteger endLine = range.end.line;
		BOOL isBreak = false;
		NSInteger insertIndex = 0;
		NSIndexSet *removeIndexSet;
		if (newLine == -1) newLine = startLine;
        //没有选中内容时,格式化当前的所有内容
		if ((startLine == endLine) && (range.start.column == range.end.column)) {
			[selectString appendString:invocation.buffer.completeBuffer];
			removeIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, invocation.buffer.lines.count)];
			isBreak = true;
		} else {
            //有选中时.取出选中行的内容
			insertIndex = startLine;
			for (NSInteger i = startLine; i <= endLine; i++) {
				[selectString appendFormat:@"%@", invocation.buffer.lines[i]];
			}
			removeIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(range.start.line, endLine + 1 - startLine)];
			isBreak = true;
		}
		NSArray *array = [self formatCodeWithString:selectString];//格式化内容
		if (array && (array.count > 0)) {//将格式化后的内容替换旧内容
			[invocation.buffer.lines removeObjectsAtIndexes:removeIndexSet];
			[invocation.buffer.lines insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertIndex, array.count)]];
		}
        if (isBreak) break;
	}

	[invocation.buffer.selections removeAllObjects];
	XCSourceTextRange *newRange = [[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(newLine, 0) end:XCSourceTextPositionMake(newLine, 0)];
	[invocation.buffer.selections addObject:newRange];
}

#pragma mark - 格式化输入文字
+ (NSArray *)formatCodeWithString:(NSString *)string {
	if (!string || (string.length == 0)) return nil;
    
	NSPipe *errorPipe = [NSPipe new];
	NSPipe *outputPipe = [NSPipe new];

	NSTask *task = [NSTask new];

	task.standardError = errorPipe;
	task.standardInput = string;
	task.standardOutput = outputPipe;
	NSString *commandPath = [[NSBundle mainBundle] pathForResource:@"uncrustify" ofType:nil];
	task.launchPath = commandPath;

	// configure uncrustify to format with bundled uncrustify.cfg, format for Objective-C, and strip messages
	NSString *commandConfigPath = [NSString stringWithFormat:@"-c=%@", [[NSBundle mainBundle] pathForResource:@"uncrustify.cfg" ofType:nil]];
	task.arguments = @[commandConfigPath, @"-l=OC", @"-q"];

	NSPipe *inputPipe = [NSPipe new];
	task.standardInput = inputPipe;
	NSFileHandle *stdinHandle = inputPipe.fileHandleForWriting;

	// write text to stdin (where uncrustify reads from)
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	[stdinHandle writeData:data];
	[stdinHandle closeFile];

	[task launch];
	[task waitUntilExit];

	[[errorPipe fileHandleForReading] readDataToEndOfFile];
	NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
	NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
	NSMutableArray *array = [NSMutableArray array];
	[outputString enumerateLinesUsingBlock:^(NSString *_Nonnull line, BOOL *_Nonnull stop) {
		[array addObject:line];
	}];
	return array;
}

#pragma mark - 添加一个回车
+ (void)statementInsertEnter:(XCSourceEditorCommandInvocation *)invocation isUp:(BOOL)isUp {
    NSInteger insertIndex = -1;
    NSInteger index = 0;
    XCSourceTextRange *range = [invocation.buffer.selections firstObject];
    if (range) {
        insertIndex = range.start.line + (isUp ? 0 : 1);
        NSMutableString *insertString = [NSMutableString string];
        NSString *string = nil;
        if (insertIndex == 0 || !isUp) {
            string = invocation.buffer.lines[range.start.line];
        } else {
            string = invocation.buffer.lines[range.start.line - 1];
        }
        if (string) {
            NSUInteger length = string.length;
            NSRange range;
            for (NSUInteger i = 0; i < length; i+=range.length) {
                range = [string rangeOfComposedCharacterSequenceAtIndex:i];
                NSString *s = [string substringWithRange:range];
                if ([@" " isEqualToString:s]) {
                    [insertString appendString:s];
                } else {
                    break;
                }
            }
        }
        index = insertString.length;
        [insertString appendString:@"\n"];
        [invocation.buffer.lines insertObject:insertString atIndex:insertIndex];
    }
    if (insertIndex > -1) {
        [invocation.buffer.selections removeAllObjects];
        XCSourceTextRange *newRange = [[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(insertIndex, index) end:XCSourceTextPositionMake(insertIndex, index)];
        [invocation.buffer.selections addObject:newRange];
    }
}

#pragma mark - 添加一个变量的释放到dealloc
+ (void)statementInsertReleaseToDealloc:(XCSourceEditorCommandInvocation *)invocation {
    NSInteger deallocIndex = -1;
    NSMutableArray *variableArray = [NSMutableArray array];
    for (XCSourceTextRange *range in invocation.buffer.selections) {
        [variableArray removeAllObjects];
        if (range.start.line != range.end.line) {//跨行
            for (NSInteger i = range.start.line; i <= range.end.line; i++) {
                NSString *string = invocation.buffer.lines[i];
                if ([string hasPrefix:@"@property"]) {
                    if ([string rangeOfString:@"retain"].location != NSNotFound || [string rangeOfString:@"copy"].location != NSNotFound) {
                        NSArray *a = [self getVariableName:string];
                        if (a && a.count > 0) {
                            for (NSString *name in a.objectEnumerator) {
                                [variableArray addObject:[NSString stringWithFormat:@"_%@",name]];
                            }
                        }
                    }
                } else {
                    NSArray *a = [self getVariableName:string];
                    if (a && a.count > 0) [variableArray addObjectsFromArray:a];
                }
            }
        } else {
            NSString *string = invocation.buffer.lines[range.start.line];
            if ([string hasPrefix:@"@property"]) {
                if ([string rangeOfString:@"retain"].location != NSNotFound || [string rangeOfString:@"copy"].location != NSNotFound) {
                    NSArray *a = [self getVariableName:string];
                    if (a && a.count > 0) {
                        for (NSString *name in a.objectEnumerator) {
                            [variableArray addObject:[NSString stringWithFormat:@"_%@",name]];
                        }
                    }
                }
            } else {
                NSArray *a = [self getVariableName:string];
                if (a && a.count > 0) {
                    [variableArray addObjectsFromArray:a];
                } else if (range.start.column != range.end.column) {
                    [variableArray addObject:[string substringWithRange:NSMakeRange(range.start.column, range.end.column - range.start.column)]];
                }
            }
        }
        if (deallocIndex == -1) {
            NSUInteger count = invocation.buffer.lines.count;
            //获取@implementation的位置
            NSUInteger startIndex = [Until findStringIndex:@"@implementation" endString:@"@interface" findRang:NSMakeRange(range.start.line, count) allString:invocation.buffer.lines isOrder:false];
            NSUInteger endIndex = -1;
            if (startIndex >= count) {//在查找implementation时,遇到interface
                NSString *string = invocation.buffer.lines[startIndex -count];
                NSRange r = [string rangeOfString:@"@interface"];
                NSRange r1 = [string rangeOfString:@"("];
                NSRange r2 = [string rangeOfString:@":"];
                NSRange endR = r1.location != NSNotFound ? r1 : r2;
                NSString *name = nil;//获取interface后面的实体名称
                if (r.location != NSNotFound && endR.location != NSNotFound && r.location < endR.location) {
                    name = [string substringWithRange:NSMakeRange(r.location + r.length, endR.location-r.location-r.length)];
                    name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
                    // 查找implementation+实体名称
                    startIndex = [Until findStringIndex:[NSString stringWithFormat:@"@implementation %@",name] endString:nil findRang:NSMakeRange(0, count) allString:invocation.buffer.lines isOrder:true];
                    if (startIndex != -1) {//如果存在,则查找end的位置
                        endIndex = [Until findStringIndex:@"@end" endString:nil findRang:NSMakeRange(startIndex, count - range.start.line) allString:invocation.buffer.lines isOrder:true];
                    }
                } else {//不存在实体名称时
                    startIndex = -1;
                }
            }
            
            if (startIndex == -1) {
                startIndex = [Until findStringIndex:@"@implementation" endString:nil findRang:NSMakeRange(range.start.line, count) allString:invocation.buffer.lines isOrder:true];
                endIndex = [Until findStringIndex:@"@end" endString:nil findRang:NSMakeRange(range.start.line, count - range.start.line) allString:invocation.buffer.lines isOrder:true];
            }
            
            //获取dealloc的位置
            NSRange searchRange = NSMakeRange(startIndex, endIndex - startIndex - 1);
            if (endIndex == -1 || startIndex == -1 || endIndex <= startIndex) searchRange = NSMakeRange(0, count);
            deallocIndex = [self findMethodIndex:@"dealloc" findRang:searchRange allString:invocation.buffer.lines];
            
            if (deallocIndex == -1) {//不存在dealloc时,在end前一行插入dealloc方法
                deallocIndex = endIndex - 1;
                [invocation.buffer.lines insertObject:@"- (void)dealloc {\n    [super dealloc];\n}" atIndex:++deallocIndex];
            }
        }
        for (NSString *name in variableArray.objectEnumerator) {
            NSString *releaseString = [NSString stringWithFormat:@"	RELEASE(%@);",name];
            [invocation.buffer.lines insertObject:releaseString atIndex:++deallocIndex];
        }
    }
}

/**
 *  @brief  从一字符串中获取所有的变量名
 *
 *  @param string <#string description#> 
 *
 *  @return <#return description#> 
 */ 
+ (NSArray *)getVariableName:(NSString *)string {
    BOOL isStart = false;
    NSMutableArray *variableArray = [NSMutableArray array];
    NSInteger startIndex = -1;
    NSInteger endIndex = -1;
    for (NSInteger i = string.length - 1; i >= 0; i--) {
        char sub = [string characterAtIndex:i];
        if (sub == ';' || sub == '=') {// 以;和=为变量名的识别开始
            isStart = true;
            continue;
        }
        if (isStart) {
            if (endIndex == -1) {
                if (sub == ' ' || sub == '\n') {//排队空格和回车
                    continue;
                } else if ((sub >= '0' && sub <= '9') || sub == '_' ||//符合变量名命名
                           (sub >= 'a' && sub <= 'z') || (sub >= 'A' && sub <= 'Z')) {
                    startIndex = -1;
                    endIndex = i;
                } else {
                    isStart = false;
                }
            } else {
                BOOL isSelf = false;//标记变量名前是否有self
                if ((sub >= '0' && sub <= '9') || sub == '_' ||//符合变量名命名,继续
                    (sub >= 'a' && sub <= 'z') || (sub >= 'A' && sub <= 'Z')) {
                    startIndex = i;
                    continue;
                } else if (i == 0) {//如果到了开头,则完全符合
                    startIndex = 0;
                } else if (sub == ' ' || sub == '*') {//如果是空格或者"*",就要判断后面的一个字母是否符合变量命名
                    char c = [string characterAtIndex:i + 1];
                    if (c == '_' || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) {
                        startIndex = i + 1;
                    } else {
                        isStart = false;
                        startIndex = -1;
                        endIndex = -1;
                    }
                } else if (sub == '.') {//如果是.,就是判断是否是"self."
                    if (i >= 4) {//如果.前面有超过4个字符
                        NSString *s = [string substringWithRange:NSMakeRange(i-4, 4)];
                        //判断前面的4个字符是否是self
                        if ([@"self" isEqualToString:s]) {
                            startIndex = i + 1;
                            isSelf = true;
                        } else {
                            isStart = false;
                            startIndex = -1;
                            endIndex = -1;
                        }
                    } else {
                        isStart = false;
                        startIndex = -1;
                        endIndex = -1;
                    }
                } else {
                    startIndex = -1;
                    endIndex = -1;
                    isStart = false;
                }
                if (isStart && startIndex > -1) {
                    NSString *name = [string substringWithRange:NSMakeRange(startIndex, endIndex - startIndex + 1)];
                    if (isSelf) {
                        i -= 4;
                        name = [NSString stringWithFormat:@"_%@",name];
                    }
                    [variableArray addObject:name];
                    startIndex = -1;
                    endIndex = -1;
                    isStart = false;
                }
            }
        }
    }
    return variableArray;
}


/**
 *  @brief  查找方法{所在行
 *
 *  @param methodName 方法名
 *  @param range      查找范围
 *  @param allString  所有文字(NSArray<NSString *>类型)
 *
 *  @return 目标文字所在行,不存在是返回-1
 */ 
+ (NSInteger)findMethodIndex:(NSString *)methodName findRang:(NSRange)range allString:(NSArray<NSString *> *)allString {
    if (!methodName || methodName.length == 0 || !allString || allString.count == 0) return -1;
    NSUInteger count = allString.count;
    if (count > range.location + range.length) count = range.location + range.length;
    BOOL isStartSearch = false;
    NSUInteger startIndex = 0;
    for (NSUInteger i = range.location; i < count; i++) {
        startIndex = 0;//开始查找方法名结束
        NSString *string = allString[i];
        NSRange r = [string rangeOfString:methodName];
        if (r.location != NSNotFound) {//当前行有方法名
            isStartSearch = true;//设置可以查找
            startIndex = r.location + r.length;//当前行的查找开始位置为方法名后
        }
        if (isStartSearch) {
            for (NSInteger j = startIndex; j < string.length; j++) {
                char sub = [string characterAtIndex:j];
                if (sub == ' ' || sub == ';' || sub == '\n') {//方法名后为这些时,继续查找
                    continue;
                } else if (sub == '{') {//查找到{时,表示查找到了结果
                    return i;
                } else {//出现其他字符时,表示不是要查找的方法
                    isStartSearch = false;
                }
            }
        }
    }
    return -1;
}

@end
