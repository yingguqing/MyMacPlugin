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
#define BaseCommandID @"IDESourceEditorExtension:com.yingguqing.MyMacPlugin.MyPlugin,IDESourceEditorExtensionCommand:com.yingguqing.MyMacPlugin.MyPlugin"
#define BindingAlreadySet @"快捷键设置已存在,请在Xcode里查看."
#define BindingIsSet @"快捷键设置成功,请在Xcode里使用."
#define CouldNotInstall @"快捷键设置失败.请在系统设置里再试一次."

@interface KeyBindingsInserter() {
    NSString *vanillaPlistPath;
    NSArray *KeyBindArray;
}

@end

@implementation KeyBindingsInserter

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.path = path;
        vanillaPlistPath = [[NSBundle mainBundle] pathForResource:@"yingguqing" ofType:@"plist"];
        KeyBindArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserKeyBindings" ofType:@"plist"]];
        for (NSDictionary *item in KeyBindArray.objectEnumerator) {
            NSString *comId = item[CommandID];
            if (![comId hasPrefix:BaseCommandID]) {
                NSString *newComId = [NSString stringWithFormat:@"%@%@",BaseCommandID,comId];
                [item setValue:newComId forKey:CommandID];
            }
        }
        [self deleteAllOtherKey];
    }
    return self;
}

- (void)insertBindings {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
        [self installVanillaPlist];//不存在文件,就先复制一个
    }
    BOOL success = false;
    for (NSDictionary *item in KeyBindArray.objectEnumerator) {
        success = [self insertVanillaPlistWith:item];
        if (!success) break;
    }
    if (success) {
        [self present:BindingIsSet style:NSAlertStyleInformational];
    } else {
        [self present:CouldNotInstall style:NSAlertStyleCritical];
    }
}

- (void)deleteAllOtherKey {
    NSMutableDictionary *existingPlist = [NSMutableDictionary dictionaryWithContentsOfFile:_path];
    if (!existingPlist) return;
    NSMutableArray *bindings = [self extractBindingsFrom:existingPlist];
    NSMutableArray *delArray = [NSMutableArray array];
    for (NSDictionary *item in bindings.objectEnumerator) {
        NSString *comId = item[CommandID];
        if (comId && comId.length > 0) {
            if (![comId hasPrefix:@"Xcode"]) {
                [delArray addObject:item];
            }
        }
    }
    [bindings removeObjectsInArray:delArray];
    [existingPlist writeToFile:_path atomically:true];
}

- (BOOL)insertVanillaPlistWith:(NSDictionary *)newKey {
    if (newKey.count == 0 || KeyBindArray.count == 0) return false;
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
            /*if let binding = bindings[bindingPosition] as? NSDictionary,
                isBindingSet(in: binding, keyboardShortcut: KeyboardShortcut) {
                    //present(message: Messages.BindingAlreadySet, style: .informational)
                    return true
                } else {
                    bindings.removeObject(at: bindingPosition)
                    bindings.insert(newKey, at: bindingPosition)
                }*/
        } else {
            [bindings insertObject:newKey atIndex:0];
        }
        [existingPlist writeToFile:_path atomically:true];
        //present(message: Messages.BindingIsSet, style: .informational)
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

- (void)installVanillaPlist {
    NSString *keyBindingsFolder = [[NSString stringWithFormat:@"%@",_path] stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:keyBindingsFolder]) {
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:keyBindingsFolder withIntermediateDirectories:true attributes:nil error:&error];
        if (!success) [self present:error];
    }
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:vanillaPlistPath toPath:_path error:&error];
    if (success) {
        [self present:BindingIsSet style:NSAlertStyleInformational];
    } else {
        [self present:error];
    }
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
