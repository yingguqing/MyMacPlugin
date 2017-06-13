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
        print(self.contentUTI)
        return self.contentUTI == "public.objective-c-source"
    }
    
    var isSwiftSource: Bool {
        return self.contentUTI == "public.swift-source"
    }
}

class FormatCodeStatement: NSObject {    
    //MARK: 格式化代码
    static func formatCodeStatement(invocation:XCSourceEditorCommandInvocation) {
        if invocation.buffer.isOCSource {
            var newLine = -1
            for item in invocation.buffer.selections {
                let range = item as! XCSourceTextRange
                let selectString:NSMutableString = NSMutableString()
                let startLine = range.start.line
                let endLine = range.end.line
                var isBreak = false
                var insertIndex = 0
                var removeIndexSet:NSIndexSet?
                if newLine == -1 {
                    newLine = startLine
                }
                //没有选中内容时,格式化当前的所有内容
                if startLine == endLine && range.start.column == range.end.column {
                    selectString.append(invocation.buffer.completeBuffer)
                    removeIndexSet = NSIndexSet(indexesIn: NSMakeRange(0, invocation.buffer.lines.count))
                    isBreak = true
                } else {//有选中时.取出选中行的内容
                    insertIndex = startLine
                    for index in startLine ... endLine {
                        selectString.append(invocation.buffer.lines[index] as! String)
                    }
                    removeIndexSet = NSIndexSet(indexesIn: NSMakeRange(range.start.line, endLine + 1 - startLine))
                    isBreak = true
                }
                let array = formatCodeWith(string: selectString as String)//格式化内容
                if (array?.count)! > 0 {
                    invocation.buffer.lines.removeObjects(at: removeIndexSet! as IndexSet)
                    let indexSet = NSIndexSet(indexesIn: NSMakeRange(insertIndex, array!.count))
                    invocation.buffer.lines.insert(array!, at: indexSet as IndexSet)
                }
                if isBreak {break}
            }
            invocation.buffer.selections.removeAllObjects()
            let newRange = XCSourceTextRange(start: XCSourceTextPosition(line: newLine, column: 0), end: XCSourceTextPosition(line: newLine, column: 0))
            invocation.buffer.selections.add(newRange)
        }
    }
    
    //MARK:格式化输入文字
    static func formatCodeWith(string:String?) -> Array<String>? {
        guard string?.isEmpty == false else {return nil}
        let errorPipe = Pipe()
        let outputPipe = Pipe()
        let task = Process()
        task.standardError = errorPipe;
        task.standardInput = string;
        task.standardOutput = outputPipe;
        let commandPath = Bundle.main.path(forResource: "uncrustify", ofType: nil)
        task.launchPath = commandPath;
    
        // configure uncrustify to format with bundled uncrustify.cfg, format for Objective-C, and strip messages
        let commandConfigPath = "-c=" + Bundle.main.path(forResource: "uncrustify.cfg", ofType: nil)!
        task.arguments = [commandConfigPath, "-l=OC", "-q"]
        
        let inputPipe = Pipe()
        task.standardInput = inputPipe;
        let stdinHandle = inputPipe.fileHandleForWriting
    
        // write text to stdin (where uncrustify reads from)
        let data = string?.data(using: String.Encoding.utf8)
        stdinHandle.write(data!)
        stdinHandle.closeFile()
        
        task.launch()
        task.waitUntilExit()
    
        errorPipe.fileHandleForReading.readDataToEndOfFile()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data:outputData, encoding:String.Encoding.utf8)
        var array = Array<String>()
        outputString?.enumerateLines(invoking: { (line, stop) in
            array.append(line)
        })
        return array;
    }
}
