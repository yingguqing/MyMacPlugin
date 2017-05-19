//
//  ImportStatement.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/18.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import "ImportStatement.h"
#import <AppKit/AppKit.h>
#import "Until.h"

NSString *const objcImport = @".*#.*(import|include).*[\",<].*[\",>]";
NSString *const objcModuleImport = @".*@.*(import).*.;";
NSString *const swiftModuleImport = @".*(import) +.*.";

/// Double import strings
/// Note: For the `doubleImportWarningString` string, we're using a non-breaking space (\u00A0), not a normal space
NSString *const doubleImportWarningString = @"🚨 这个头文件已被导入 🚨";
NSString *const cancelRemoveImportButtonString = @"完成";


@implementation ImportStatement

static NSRegularExpression *importRegex;
static NSRegularExpression *moduleImportRegex;
static NSRegularExpression *swiftModuleImportRegex;

+ (NSRegularExpression *)importRegex {
    if (!importRegex) {
        importRegex = [NSRegularExpression regularExpressionWithPattern:objcImport options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return importRegex;
}

+ (NSRegularExpression *)moduleImportRegex {
    if (!moduleImportRegex) {
        moduleImportRegex = [NSRegularExpression regularExpressionWithPattern:objcModuleImport options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return moduleImportRegex;
}

+ (NSRegularExpression *)swiftModuleImportRegex {
    if (!swiftModuleImportRegex) {
        swiftModuleImportRegex = [NSRegularExpression regularExpressionWithPattern:swiftModuleImport options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return swiftModuleImportRegex;
}

+ (void)execute:(XCSourceEditorCommandInvocation *_Nonnull)invocation {
    //NSInteger lineToRemove = NSNotFound;
    XCSourceTextRange *selection = invocation.buffer.selections.firstObject;
    NSUInteger selectionLine = selection.start.line;
    NSString *importString = [invocation.buffer.lines[selectionLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![self isValid:importString invocation:invocation]) {
        if ([self isSwiftSource:invocation]) {
            [invocation.buffer.lines insertObject:@"import <#header#>" atIndex:selectionLine];
        } else {
            [invocation.buffer.lines insertObject:@"#import \"<#header#>\"" atIndex:selectionLine];
        }
        return;
    }
    
    NSInteger line = [self appropriateLine:selectionLine invocation:invocation];
    if (line == NSNotFound) {
        return;
    }
    
    if (![self canIncludeImportString:importString atLine:line invocation:invocation]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSInteger lineToRemove = selectionLine;
            NSAlert *doubleImportAlert = [NSAlert new];
            doubleImportAlert.messageText = doubleImportWarningString;
            [doubleImportAlert addButtonWithTitle:cancelRemoveImportButtonString];
            
            // We're creating a "fake" view so that the text doesn't wrap on two lines
            NSRect fakeRect = NSMakeRect(0, 0, 307, 0);
            NSView *fakeView = [[NSView alloc] initWithFrame:fakeRect];
            doubleImportAlert.accessoryView = fakeView;
            NSBeep();
            NSRunningApplication *frontmostApplication = [[NSWorkspace sharedWorkspace] frontmostApplication];
            NSWindow *appWindow = doubleImportAlert.window;
            [appWindow makeKeyAndOrderFront:appWindow];
            [NSApp activateIgnoringOtherApps:true];
            
            NSModalResponse response = [doubleImportAlert runModal];
            if (response == NSAlertFirstButtonReturn) {
                XCSourceTextRange *selectionPosition = [[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(0, 0) end:XCSourceTextPositionMake(0, 0)];
                [invocation.buffer.selections removeAllObjects];
                [invocation.buffer.selections insertObject:selectionPosition atIndex:0];
                [invocation.buffer.lines removeObjectAtIndex:lineToRemove];
            }
            [NSApp deactivate];
            if (frontmostApplication) {
                [frontmostApplication activateWithOptions:NSApplicationActivateAllWindows];
            }
        }];
        return;
    }
    
    [invocation.buffer.lines removeObjectAtIndex:selectionLine];
    [invocation.buffer.lines insertObject:importString atIndex:line];
    
    //add a new selection. Bug fix for #7
    XCSourceTextRange *selectionPosition = [[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(0, 0) end:XCSourceTextPositionMake(0, 0)];
    [invocation.buffer.selections removeAllObjects];
    [invocation.buffer.selections insertObject:selectionPosition atIndex:0];
}

+ (BOOL)isValid:(NSString *)importString invocation:(XCSourceEditorCommandInvocation *)invocation {
    NSInteger numberOfMatches = 0;
    NSMatchingOptions matchingOptions = NSMatchingReportProgress;
    NSRange range = NSMakeRange(0, importString.length);
    
    if ([self isSwiftSource:invocation]) {
        numberOfMatches = [self.swiftModuleImportRegex numberOfMatchesInString:importString options:matchingOptions range:range];
    } else {
        numberOfMatches = [self.importRegex numberOfMatchesInString:importString options:matchingOptions range:range];
        numberOfMatches = numberOfMatches > 0 ? numberOfMatches : [self.moduleImportRegex  numberOfMatchesInString:importString options:matchingOptions range:range];
    }
    return numberOfMatches > 0;
}

+ (NSInteger)appropriateLine:(NSInteger)ignoringLine invocation:(XCSourceEditorCommandInvocation *)invocation {
    NSInteger lineNumber = NSNotFound;
    NSArray *lines = invocation.buffer.lines;
    //Find the line that is first after all the imports
    NSUInteger index = 0;
    for (NSString *line in lines.objectEnumerator) {
        if (index == ignoringLine) {
            continue;
        }
        if ([self isValid:line invocation:invocation]) {
            lineNumber = index;
        } else if (lineNumber != NSNotFound){
            break;
        }
        index++;
    }
    
    if (lineNumber != NSNotFound) {
        return lineNumber + 1;
    }
    
    //if a line is not found, find first free line after comments
    index = 0;
    for (NSString *line in lines.objectEnumerator) {
        if (index == ignoringLine) {
            continue;
        }
        lineNumber = index;
        if ([Until isWhitespaceOrNewline:line]) {
            break;
        }
        index++;
    }
    return lineNumber + 1;
}

+ (BOOL)isSwiftSource:(XCSourceEditorCommandInvocation *)invocation {
    return [@"public.swift-source" isEqualToString:invocation.buffer.contentUTI];
}

/// Checks if the import string isn't already contained in the import list
///
/// - Parameters:
///   - importString: The import statement to include
///   - atLine: The line where the import should be done. This is to check from lines 0 to atLine
/// - Returns: true if the statement isn't already included, false if it is
+ (BOOL)canIncludeImportString:(NSString *)importString atLine:(NSInteger)atLine invocation:(XCSourceEditorCommandInvocation *)invocation {
    NSArray *importBufferArray = [invocation.buffer.lines subarrayWithRange:NSMakeRange(0, atLine)];
    return [importBufferArray containsObject:importString] == false;
}
@end
