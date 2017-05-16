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

@end
