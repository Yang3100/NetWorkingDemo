//
//  KJAESSecurityTool.h
//  MoLiao
//
//  Created by 杨科军 on 2018/7/17.
//  Copyright © 2018年 杨科军. All rights reserved.
//  加密工具

#import <Foundation/Foundation.h>

@interface KJAESSecurityTool : NSObject
/// 生成key
+ (NSString *)createKey;
/// 生成token
+ (NSString *)createToken;
/// Aes加密
+ (NSString *)aes128EncryptWith:(NSString *)value Key:(NSString *)key;
/// Aes解密
+ (NSString *)aes128DecryptWith:(NSString *)value Key:(NSString *)key;

@end
