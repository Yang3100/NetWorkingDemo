# KJNetWorkingDemo
<!--![coverImage](https://raw.githubusercontent.com/yangKJ/CommonDatas/master/CommonDatas/Res/coverImage.jpg)-->

<!--KJCachePolicyNetworkOnly先从网络获取，缓存在本地-->
Demo介绍：  
一款基于AFNetWorking和YYCache二次封装网络请求工具  
1、KJAESSecurityTool 加密和解密工具  
2、按App版本号缓存网络数据（KJCachePolicyNetworkOnly）  
3、KJBaseNetWorking 网络请求基类  
4、KJNetManager 存放所有网络请求，方便管理和查看  

----------------------------------------

#### <a id="使用方法"></a>使用方法
<!--在AppDelegate当中-->
```
/***********  配置网络信息  *************/
- (void)setNetConfig{
    /** 设置请求超时时间(默认30s) */
    [KJBaseNetWorking setRequestTimeoutInterval:20];
    /** 是否按App版本号缓存网络请求内容(默认关闭) */
    [KJBaseNetWorking setCacheVersionEnabled:YES];
    /** 输出Log信息开关(默认打开) */
    [KJBaseNetWorking setLogEnabled:YES];
    /** 配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了 */
    [KJBaseNetWorking setHeadr:nil]; /// 中英文语言时候一般会用到
    /** 设置接口根路径, 设置后所有的网络访问都使用相对路径 尽量以"/"结束 */
    [KJBaseNetWorking setBaseURL:[KJxcconfig shareConfig].serverAddress];
    /** 设置接口基本参数(如:用户ID, Token) */
    [KJBaseNetWorking setBaseParameters:[KJNetManager commonParams]];
}
```
调用方式  

```
[KJNetManager kCustomNetWorkingPOSTWithURL:@"URL地址" parameters:@"参数" cachePolicy:@"缓存方式" callback:^(id responseObject, BOOL isCache, NSError *error) { 
    NSLog(@"返回数据：%@",responseObject);
}];
```
