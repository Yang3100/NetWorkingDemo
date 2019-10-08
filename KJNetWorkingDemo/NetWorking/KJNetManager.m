//
//  KJNetManager.m
//  MoLiao
//
//  Created by 杨科军 on 2018/7/17.
//  Copyright © 2018年 杨科军. All rights reserved.
//

#import "KJNetManager.h"

@implementation KJNetManager

#pragma mark - 公用的请求参数  加密解密
// 公用的请求参数
+ (NSMutableDictionary *)commonParams{
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    /// token
    NSString *token;
    if ((![kTOKEN isEqualToString:@""]) && (kTOKEN != nil)) {
        token = kTOKEN;
    }else{
        token = [KJAESSecurityTool createToken];  /// 生成对应的token
        [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"token"];
    }
    [paramDic setObject:token forKey:@"token"];  // 公共参数
//    /// app版本
//    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [paramDic setObject:appVersion forKey:@"versionCode"];  // 版本号
    return paramDic;
}

/// 加密数据
+ (NSDictionary *)encryptParameters:(NSDictionary *)parameters{
#ifdef DEBUG
    NSLog(@"\n============>>>>>>>>>>😎 原始参数 😎<<<<<<<<<<============ \n%@\n", [self kj_jsonToString:parameters]);
#endif
    if (parameters && kPrivateKey) {
        NSString *paramString = [self kj_jsonToString:parameters]; /// 将字典转为字符串
        NSString *decryptString = [KJAESSecurityTool aes128EncryptWith:paramString Key:kPrivateKey];
        return @{@"data":decryptString};
    }
    return parameters;
}
/// 解密数据
+ (NSDictionary *)decryptParameters:(NSDictionary *)parameters{
    NSString *data = parameters[@"data"];
    if (data) {
        NSString *decryptString = [KJAESSecurityTool aes128DecryptWith:data Key:kPrivateKey];
        NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        if (![decryptString isEqualToString:@""] && decryptString != nil) {
            /// 字符串转id
            id dd = [self kj_dictionaryWithJsonString:decryptString];
            [mutableDic setObject:dd forKey:@"data"];
        }
        return mutableDic;
    }
    return parameters;
}

#pragma mark - 网络请求中转判断处理 - 包含密钥失效处理
+ (void)kCustomNetWorkingPOSTWithURL:(NSString *)url parameters:(NSDictionary *)parameters cachePolicy:(KJCachePolicy)cachePolicy callback:(KJHttpRequest)callback{
    /// 加密数据
    parameters = [self encryptParameters:parameters];
    [self POSTWithURL:url parameters:parameters cachePolicy:cachePolicy callback:^(id responseObject, BOOL isCache, NSError *error) {
        /// 密钥失效
        if ([responseObject[@"code"] integerValue] == KJHTTPCodeNeedSyncPrivateKey) {
            [KJNetManager kGetPrivateKeyCompletionHandler:^(id responseObj, NSError *error) {
                if (CODE == KJHTTPCodeSuccess) {
                    /// 保存密钥到NSUserDefaults
                    [[NSUserDefaults standardUserDefaults] setValue:responseObj[@"privateKey"] forKey:@"privateKey"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    /// 递归 - 获取到密钥之后重新获取数据
                    [self kCustomNetWorkingPOSTWithURL:url parameters:parameters cachePolicy:cachePolicy callback:callback];
                }
            }];
        }else{
            /// 解密数据
            NSDictionary *dict = [self decryptParameters:responseObject];
#ifdef DEBUG
            NSLog(@"\n============>>>>>>>>>>😎 解密之后的数据 😎>>>>>>>>>>============\n%@",[self kj_jsonToString:dict]);
#endif
            !callback?:callback(dict,isCache,error);
        }
    }];
}

#pragma mark - 密钥相关
/// 获取密钥
+ (void)kGetPrivateKeyCompletionHandler:(void(^)(id responseObj, NSError *error))completionHandler{
    NSString *pulicKey = kPulicKey; /// 公钥
    NSString *privateKey = [KJAESSecurityTool createKey];  
    /// 加密私钥
    NSString *encryptkey = [KJAESSecurityTool aes128EncryptWith:privateKey Key:pulicKey];
    if (!encryptkey) {
        NSError *error = [NSError errorWithDomain:@"同步私钥失败" code:KJHTTPCodeNeedSyncPrivateKey userInfo:nil];
        !completionHandler ?: completionHandler(nil,error);
        return;
    }
    NSString *deviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSDictionary *parameters = @{@"key":encryptkey,
                                 @"deviceid":deviceId,  /// 设备ID
                                 @"devicetype":@"ios",
                                 };
    [self POSTWithURL:@"" parameters:parameters cachePolicy:(KJCachePolicyIgnoreCache) callback:^(id responseObject, BOOL isCache, NSError *error) {
        if ([[responseObject valueForKey:@"code"] integerValue] == KJHTTPCodeSuccess) {
            NSDictionary *dict = @{@"code":@(KJHTTPCodeSuccess),
                                   @"privateKey":privateKey
                                   };
            !completionHandler?:completionHandler(dict, nil);
            return;
        }
        if (error != nil) {
            !completionHandler?:completionHandler(nil, error);
        }
    }];
}

#pragma mark - 上传图片
+ (void)kUploadImage:(NSArray<UIImage*>*)images Name:(NSString*)name Parameters:(NSDictionary*)parameters Progress:(void(^)(NSProgress *progress))pro CompletionHandler:(void(^)(id responseObj, NSError *error))completionHandler{
    /// 获取公共参数
    NSMutableDictionary *dict = [KJNetManager commonParams];
    [dict addEntriesFromDictionary:parameters]; /// 拼接参数
    NSString *url = @"完整上传链接地址";//[[KJxcconfig shareConfig].serverAddress stringByAppendingString:@""];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    NSString *fileName = [formatter stringFromDate:[NSDate date]];
    [self uploadImageURL:url parameters:dict images:images name:name fileName:fileName mimeType:@"png" progress:^(NSProgress *progress) {
        !pro ?: pro(progress);
    } callback:^(id responseObject, BOOL isCache, NSError *error) {
        /// 密钥失效
        if ([responseObject[@"code"] integerValue] == KJHTTPCodeNeedSyncPrivateKey) {
            /// 清楚保存密钥
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"privateKey"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [KJNetManager kGetPrivateKeyCompletionHandler:^(id responseObj, NSError *error) {
                if (CODE == KJHTTPCodeSuccess) {
                    /// 保存密钥到NSUserDefaults
                    [[NSUserDefaults standardUserDefaults] setValue:responseObj[@"privateKey"] forKey:@"privateKey"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    /// 递归 - 获取到密钥之后重新获取数据
                    [self kUploadImage:images Name:name Parameters:parameters Progress:pro CompletionHandler:completionHandler];
                }
            }];
        }else{
            /// 解密数据
            NSDictionary *dict = [self decryptParameters:responseObject];
#ifdef DEBUG
            NSLog(@"\n============>>>>>>>>>>😎 解密之后的数据 😎>>>>>>>>>>============\n%@",[self kj_jsonToString:dict]);
#endif
            !completionHandler ?: completionHandler(dict,error);
        }
    }];
}

#pragma mark - 登陆注册版块
/// 获取验证码
+ (void)kLoginGetCodeWithPhone:(NSString*)phone Type:(NSString*)type CompletionHandler:(void(^)(id responseObj, NSError *error))completionHandler{
    NSDictionary *parameters = @{@"mobile":phone,
                                 @"usefulness":type, //1-快速登录 2-手机号注册  3-重置密码 4-手机认证
                                 };
    [self kCustomNetWorkingPOSTWithURL:@"" parameters:parameters cachePolicy:(KJCachePolicyIgnoreCache) callback:^(id responseObject, BOOL isCache, NSError *error) {
        !completionHandler ?: completionHandler(responseObject,error);
    }];
}


@end
