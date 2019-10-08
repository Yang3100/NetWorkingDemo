//
//  AppDelegate.m
//  KJNetWorkingDemo
//
//  Created by 杨科军 on 2019/10/8.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "AppDelegate.h"
#import "KJNetManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setNetConfig];
    
    [KJNetManager kCustomNetWorkingPOSTWithURL:@"URL地址" parameters:@"参数" cachePolicy:@"缓存方式" callback:^(id responseObject, BOOL isCache, NSError *error) {
        NSLog(@"返回数据：%@",responseObject);
    }];
    
    return YES;
}

/***********  配置网络信息  *************/
- (void)setNetConfig{
    /**设置请求超时时间(默认30s) */
    [KJBaseNetWorking setRequestTimeoutInterval:20];
    /**是否按App版本号缓存网络请求内容(默认关闭)*/
    [KJBaseNetWorking setCacheVersionEnabled:YES];
    /**输出Log信息开关(默认打开)*/
    [KJBaseNetWorking setLogEnabled:YES];
    /** 配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了 */
    [KJBaseNetWorking setHeadr:nil]; /// 中英文语言时候一般会用到
    /**设置接口根路径, 设置后所有的网络访问都使用相对路径 尽量以"/"结束*/
//    [KJBaseNetWorking setBaseURL:[KJxcconfig shareConfig].serverAddress];
    /** 设置接口基本参数(如:用户ID, Token) */
    [KJBaseNetWorking setBaseParameters:[KJNetManager commonParams]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
