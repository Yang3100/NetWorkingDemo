//
//  KJNetManager.h
//  MoLiao
//
//  Created by 杨科军 on 2018/7/17.
//  Copyright © 2018年 杨科军. All rights reserved.
//  所有网络请求接口

#import "KJBaseNetWorking.h"
#define CODE         [[responseObj valueForKey:@"code"] integerValue]
#define kTOKEN       [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]  /// token
#define kPrivateKey  [[NSUserDefaults standardUserDefaults] objectForKey:@"privateKey"] /// 密钥
#define kPulicKey    @"" /// 公钥

// 请求数据返回的状态码
typedef NS_ENUM(NSUInteger, KJHTTPResponseCode){
    // CODE 对应值  (PS：根据自身项目去设置)
    KJHTTPCodeSuccess = 100,  // 请求成功
    KJHTTPCodeNeedSyncPrivateKey = 500, //须重新同步私钥
};

@interface KJNetManager : KJBaseNetWorking

#pragma mark - 公用的请求参数  加密解密
+ (NSMutableDictionary *)commonParams;
/// 加密数据
+ (NSDictionary *)encryptParameters:(NSDictionary *)parameters;
/// 解密数据
+ (NSDictionary *)decryptParameters:(NSDictionary *)parameters;

#pragma mark - 上传图片
+ (void)kUploadImage:(NSArray<UIImage*>*)images Name:(NSString*)name Parameters:(NSDictionary*)parameters Progress:(void(^)(NSProgress *progress))pro CompletionHandler:(void(^)(id responseObj, NSError *error))completionHandler;

#pragma mark - 通用网络请求 - 包含密钥失效处理
+ (void)kCustomNetWorkingPOSTWithURL:(NSString *)url parameters:(NSDictionary *)parameters cachePolicy:(KJCachePolicy)cachePolicy callback:(KJHttpRequest)callback;

#pragma mark - 登陆注册版块
/// 获取验证码  type:1-快速登录 2-手机号注册  3-重置密码 4-手机认证
+ (void)kLoginGetCodeWithPhone:(NSString*)phone Type:(NSString*)type CompletionHandler:(void(^)(id responseObj, NSError *error))completionHandler;

@end
