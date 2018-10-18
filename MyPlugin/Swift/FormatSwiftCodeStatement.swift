//
//  FormatCodeStatement.swift
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/6/13.
//  Copyright © 2017年 影孤清. All rights reserved.
//

import XcodeKit

extension XCSourceTextBuffer {
    var isOCSource:Bool {
        return self.contentUTI == "public.objective-c-source"
    }
    
    var isSwiftSource: Bool {
        return ["public.swift-source", "com.apple.dt.playground"].contains(self.contentUTI)
    }
}

class FormatSwiftCodeStatement:NSObject {
    
    //MARK: 格式化代码
    @objc public class func formatSwiftCodeStatement(invocation:XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        // Grab the selected source to format
        let sourceToFormat = invocation.buffer.completeBuffer
        let tokens = tokenize(sourceToFormat)
        
        // Infer format options
        var options = inferOptions(from: tokens)
        options.indent = indentationString(for: invocation.buffer)
        
        do {
            let rules = FormatRules.all(named:
                RulesStore()
                    .rules
                    .filter { $0.isEnabled }
                    .map { $0.name }
            )
            
            let output = try format(tokens, rules: rules, options: options)
            if output == tokens {
                // No changes needed
                return completionHandler(nil)
            }
            
            // Remove all selections to avoid a crash when changing the contents of the buffer.
            invocation.buffer.selections.removeAllObjects()
            
            // Update buffer
            invocation.buffer.completeBuffer = sourceCode(for: output)
            
            // For the time being, set the selection back to the last character of the buffer
            guard let lastLine = invocation.buffer.lines.lastObject as? String else {
                return completionHandler(FormatCommandError.invalidSelection)
            }
            let position = XCSourceTextPosition(line: invocation.buffer.lines.count - 1, column: lastLine.count)
            let updatedSelectionRange = XCSourceTextRange(start: position, end: position)
            invocation.buffer.selections.add(updatedSelectionRange)
            
            return completionHandler(nil)
        } catch let error {
            return completionHandler(NSError(
                domain: "SwiftFormat",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "\(error)"]
            ))
        }
    }
    
    /// Given a source text range, an original source string and a modified target string this
    /// method will calculate the differences, and return a usable XCSourceTextRange based upon the original.
    ///
    /// - Parameters:
    ///   - textRange: Existing source text range
    ///   - sourceText: Original text
    ///   - targetText: Modified text
    /// - Returns: Source text range that should be usable with the passed modified text
    private func rangeForDifferences(in textRange : XCSourceTextRange,
                                     between _ : String, and targetText : String)->XCSourceTextRange {
        // Ensure that we're not greedy about end selections — this can cause empty lines to be removed
        let lineCountOfTarget = targetText.components(separatedBy: CharacterSet.newlines).count
        let finalLine = (textRange.end.column > 0) ? textRange.end.line : textRange.end.line - 1
        let range = textRange.start.line...finalLine
        let difference = range.count - lineCountOfTarget
        let start = XCSourceTextPosition(line: textRange.start.line, column: 0)
        let end = XCSourceTextPosition(line: finalLine - difference, column: 0)
        
        return XCSourceTextRange(start: start, end: end)
    }
}
