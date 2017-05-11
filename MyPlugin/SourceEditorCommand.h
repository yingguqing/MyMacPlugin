//
//  SourceEditorCommand.h
//  MyPlugin
//
//  Created by 影孤清 on 16/9/19.
//  Copyright © 2016年 影孤清. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface SourceEditorCommand : NSObject <XCSourceEditorCommand>
@property (nonatomic) BOOL isSwift;
@end
