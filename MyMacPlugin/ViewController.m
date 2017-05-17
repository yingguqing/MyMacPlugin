//
//  ViewController.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/17.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import "ViewController.h"
#import "KeyBindingsInserter.h"

@interface ViewController () {
	KeyBindingsInserter *keyBinding;
}

@end

#define KeyBindingsPath @"/Library/Developer/Xcode/UserData/KeyBindings/yingguqing.idekeybindings"
// #define KeyBindingsPath @"/Desktop/yingguqing.idekeybindings"

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	NSString *keyBindingsPath = [NSHomeDirectory() stringByAppendingPathComponent:KeyBindingsPath];
	keyBinding = [[KeyBindingsInserter alloc] initWithPath:keyBindingsPath];
}

- (IBAction)installKeyBindings:(NSButton *)sender {
	[keyBinding insertBindings];
}

@end
