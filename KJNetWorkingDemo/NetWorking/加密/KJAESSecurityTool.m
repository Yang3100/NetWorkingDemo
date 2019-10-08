//
//  KJAESSecurityTool.m
//  MoLiao
//
//  Created by 杨科军 on 2018/7/17.
//  Copyright © 2018年 杨科军. All rights reserved.
//

#import "KJAESSecurityTool.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation KJAESSecurityTool

/// 生成key
+ (NSString *)createKey {
    NSUInteger size = 16;
    char data[size];
    for (int x=0;x<size;x++) {
        int randomint = arc4random_uniform(2);
        if (randomint == 0) {
            data[x] = (char)('a' + (arc4random_uniform(26)));
        } else {
            data[x] = (char)('0' + (arc4random_uniform(9)));
        }
    }
    return [[NSString alloc] initWithBytes:data length:size encoding:NSUTF8StringEncoding];
}

/// 生成token
+ (NSString *)createToken {
    return [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (NSString *)aes128EncryptWith:(NSString *)value Key:(NSString *)key {
    NSData *aesData = [self aes128operation:kCCEncrypt data:[value dataUsingEncoding:NSUTF8StringEncoding] key:key];
    return [aesData base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
}

+ (NSString *)aes128DecryptWith:(NSString *)value Key:(NSString *)key {
    NSData *data = [self aes128operation:kCCDecrypt data:[[NSData alloc] initWithBase64EncodedString:value options:0] key:key];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSData *)aes128operation:(CCOperation)operation data:(NSData *)data key:(NSString *)key {
    char keyPtr[kCCKeySizeAES128 + 1];  //kCCKeySizeAES128是加密位数 可以替换成256位的
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptorStatus = CCCrypt(operation, kCCAlgorithmAES,
                                            kCCOptionPKCS7Padding | kCCOptionECBMode,
                                            keyPtr, kCCKeySizeAES128, NULL,
                                            [data bytes], [data length],
                                            buffer, bufferSize,
                                            &numBytesEncrypted);
    if (cryptorStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    if (buffer) free(buffer);
    return nil;
}

@end
