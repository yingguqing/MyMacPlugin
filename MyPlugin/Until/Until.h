//
//  Until.h
//  MyMacPlugin
//
//  Created by 影孤清 on 2017/5/15.
//  Copyright © 2017年 影孤清. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Until : NSObject
+ (void)showMsg:(NSString *)msg;
+ (BOOL)isWhitespaceOrNewline:(NSString *)str;
+ (NSString *)deleteFirstSpace:(NSString *)oldString;
+ (NSString *)nameForNo_WithName:(NSString *)name;
@end
