//
//  KeyBindingsInserter.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/17.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import "KeyBindingsInserter.h"
#import <Cocoa/Cocoa.h>

#define Title @"Title"
#define MenuKeyBindings @"Menu Key Bindings"
#define KeyBindings @"Key Bindings"
#define CommandID @"CommandID"
#define KeyboardShortcut @"Keyboard Shortcut"
#define BindingAlreadySet @"快捷键设置已存在,请在Xcode里查看."
#define BindingIsSet @"快捷键设置成功,请在Xcode里使用."
#define CouldNotInstall @"快捷键设置失败.请在系统设置里再试一次."

@interface KeyBindingsInserter() {
    NSString *vanillaPlistPath;
}


@end

@implementation KeyBindingsInserter

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.path = path;
        vanillaPlistPath = [[NSBundle mainBundle] pathForResource:@"yingguqing" ofType:@"idekeybindings"];
        self.KeyBindArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserKeyBindings" ofType:@"plist"]];
        NSString *bunldId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *baseCommandId = [NSString stringWithFormat:@"IDESourceEditorExtension:%@.MyPlugin,IDESourceEditorExtensionCommand:yingguqing",bunldId];
        for (NSDictionary *item in _KeyBindArray.objectEnumerator) {
            NSString *comId = item[CommandID];
            if (![comId hasPrefix:baseCommandId]) {
                NSString *newComId = [baseCommandId stringByAppendingString:comId];
                [item setValue:newComId forKey:CommandID];
            }
        }
    }
    return self;
}

- (void)insertBindings {
    // 快捷键绑定文件不存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:_path] == false) {
        if ([self installVanillaPlist] == false) {// 复制文件失败
            return;
        }
    }
    BOOL success = false;
    for (NSDictionary *item in _KeyBindArray.objectEnumerator) {
        success = [self insertVanillaPlistWith:item];
        if (!success) break;
    }
    if (success) {
        [self present:BindingIsSet style:NSAlertStyleInformational];
    } else {
        [self present:CouldNotInstall style:NSAlertStyleCritical];
    }
}

- (void)deleteAllOtherKeyWithPath:(NSString *)path {
    NSMutableDictionary *existingPlist = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!existingPlist) return;
    NSMutableArray *bindings = [self extractBindingsFrom:existingPlist];
    NSMutableArray *delArray = [NSMutableArray array];
    for (NSDictionary *item in bindings.objectEnumerator) {
        NSString *comId = item[CommandID];
        if (comId && comId.length > 0) {
            if (![comId hasPrefix:@"Xcode"]) {
                [delArray addObject:item];
                continue;
            }
        }
    }
    [bindings removeObjectsInArray:delArray];
    [NSFileManager.defaultManager removeItemAtPath:path error:nil];
    [existingPlist writeToFile:path atomically:true];
}

- (BOOL)insertVanillaPlistWith:(NSDictionary *)key {
    if (key.count == 0 || _KeyBindArray.count == 0) return false;
    // enable 为false的时候，不加入快捷方式
    if ([key[@"Enable"] boolValue] == false) return true;
    NSMutableDictionary *newKey = [key mutableCopy];
    [newKey removeObjectForKey:@"Enable"];
    [newKey removeObjectForKey:@"ShowShortcut"];
    NSMutableDictionary *existingPlist = [NSMutableDictionary dictionaryWithContentsOfFile:_path];
    if (!existingPlist) return false;
    NSMutableArray *bindings = [self extractBindingsFrom:existingPlist];
    if (bindings) {
        NSString *commandId = newKey[CommandID];
        NSString *keyboardShortcut = newKey[KeyboardShortcut];
        NSInteger bindingPosition = [self positionIn:bindings commandID:commandId];
        if (bindingPosition != NSNotFound) {
            NSDictionary *binding = bindings[bindingPosition];
            if (binding && [binding isKindOfClass:[NSDictionary class]]) {
                BOOL success = [self isBindingSetIn:binding keyboardShortcut:keyboardShortcut];
                if (success) {
                    return true;
                }
            }
            [bindings removeObjectAtIndex:bindingPosition];
            [bindings insertObject:newKey atIndex:bindingPosition];
        } else {
            [bindings insertObject:newKey atIndex:0];
        }
        [existingPlist writeToFile:_path atomically:true];
        return true;
    } else {
        return false;
    }
}

- (NSMutableArray *)extractBindingsFrom:(NSDictionary *)plist {
    NSDictionary *menuKeyBindings = plist[MenuKeyBindings];
    if (menuKeyBindings) {
        NSMutableArray *keyBindings = menuKeyBindings[KeyBindings];
        return keyBindings;
    }
    return nil;
}

- (NSInteger)positionIn:(NSMutableArray *)bindings commandID:(NSString *)commandID {
    if (![bindings isKindOfClass:[NSArray class]]) return NSNotFound;
    __block NSInteger index = NSNotFound;
    [bindings enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([commandID isEqualToString:obj[CommandID]]) {
            index = idx;
            *stop = true;
        }
    }];    
    return index;
}

- (BOOL)isBindingSetIn:(NSDictionary *)dictionary keyboardShortcut:(NSString *)keyboardShortcutl {
    id ob = dictionary[KeyboardShortcut];
    if (ob && [ob isKindOfClass:[NSString class]] && [keyboardShortcutl isEqualToString:ob]) {
        return true;
    }
    return false;
}

- (BOOL)installVanillaPlist {
    NSString *keyBindingsFolder = [[NSString stringWithFormat:@"%@",_path] stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:keyBindingsFolder]) {
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:keyBindingsFolder withIntermediateDirectories:true attributes:nil error:&error];
        if (!success) [self present:error];
    }
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:vanillaPlistPath toPath:_path error:&error];
    if (!success) {
        [self present:error];
    }
    return success;
}

- (void)present:(NSString *)message style:(NSAlertStyle)style {
    NSAlert *alert = [NSAlert new];
    alert.messageText = (style == NSAlertStyleInformational) ? @"👍" : @"🤕";
    alert.informativeText = message;
    alert.alertStyle = style;
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (void)present:(NSError *)error {
    if (!error) return;
    [self present:error.localizedDescription style:NSAlertStyleCritical];
}

@end
