//
//  RuleSelectionTableCellView.m
//  MyMacPlugin
//
//  Created by 影孤清 on 2018/5/3.
//  Copyright © 2018年 影孤清. All rights reserved.
//

#import "RuleSelectionTableCellView.h"
#import "RuleViewModel.h"

@interface RuleSelectionTableCellView() {
    RuleViewModel *_objectValue;
}
@end

@implementation RuleSelectionTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)toggleRuleValue:(NSButton *)sender {
    if (_objectValue) {
        _objectValue.isEnabled = (sender.state == NSControlStateValueOn);
    }
}

- (id)objectValue {
    return _objectValue;
}

- (void)setObjectValue:(id)objectValue {
    if ([objectValue isKindOfClass:[RuleViewModel class]]) {
        _objectValue = objectValue;
        _checkbox.title = _objectValue.name;
        _checkbox.state = _objectValue.isEnabled ? NSControlStateValueOn : NSControlStateValueOff;
    } else {
        _objectValue = nil;
    }
}

@end
