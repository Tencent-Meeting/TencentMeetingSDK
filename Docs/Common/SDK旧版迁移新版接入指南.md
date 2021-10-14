# 本文的作用
因为新版SDK的接口做了多项优化和调整，因此，对于已经接入过旧版SDK的客户，需要做一些小改动才能使用新版SDK。
本文将提供指引，介绍如何快速修改部分代码，就能接入到新版的SDK上来。

# 什么是新版？什么是旧版？
- 新版SDK是指：2.18.x及以上的版本
- 旧版SDK是指：2.3.x的版本

# 新版有什么不同？
首先，版本上跨越了十几个版本，新增了不少功能，例如：
1. 支持显示会议二维码
2. 客户端跳转官网已结束会议列表带登陆态
3. 屏幕共享支持人像叠加模式
4. Mac Apple Silicon M1适配
5. 超过6人入会自动静音优化
6. 录制启动异常提醒优化 + 录制封面
7. 增加个人笔记功能
8. 支持在线大会webinar
9. 支持分组讨论会议；
10. 支持内外部会议；
11. 支持等候室聊天功能；
12. webinar问答功能
13. 工具箱应用
14. iPad适配

同时，SDK接口层的设计也做了优化设计，比之前更好接入和使用。


# SDK接入调整

## 1. 接入环境
新版SDK接入的环境上与旧版相似，可参考各端的接入手册，按照步骤检查接入前的准备工作。
 
## 2. 初始化
初始化的调用上，param参数基本一样，只是会区分公有云和私有化的参数，对于公有云SaaS SDK只考虑公有云相关参数即可。

旧版SDK的初始化大部分没有初始化回调的函数，而新版SDK都具备有SDK的回调，其中包括初始化回调信息。

因此，初始化函数新增一个回调接口参数，函数形式如下：
```
void initialize(InitParam init_param, SDKCallback callback)
```
具体接口函数格式请参考[TencentMeetingSDK（TMSDK）接口参考文档](../Common/TencentMeetingSDK（TMSDK）接口参考文档.md)

`注意`：响应SDK初始化回调 onSDKInitializeResult ， `回调结果成功才表示初始化完成`

## 3.回调的方法
- 在旧版SDK中，各类回调响应是通过调用类似setXXXCallback函数来实现设置。
- 在新版SDK中，各类回调会在对应的service中来统一设置，例如：登录相关的回调，在`AccountService`的`setAuthenticationCallback`函数来设置；
而入会的回调，是在`PreMeetingService`的`setPreMeetingCallback`函数来设置。

## 4. 登录登出
- 在旧版SDK中，登录函数只是login()，没有传任何参数，函数会先判断之前是否登录过，如果本地有登录信息会快速登录，然后回调onLogin中表示成功。
如果不能快速登录，则回调 onAuthCodeRefresh，并需要客户设置sso url。

- 新版SDK登录函数login是在AccountService中，并直接将sso url作为参数传入进来，不用去响应类似onAuthCodeRefresh这样的回调， 
在`AuthenticationCallback.onLogin`中响应登录结果即可。

```
void login(string sso_url)
```
具体接口函数格式请参考[TencentMeetingSDK（TMSDK）接口参考文档](../Common/TencentMeetingSDK（TMSDK）接口参考文档.md)

## 5. 入会
新旧版SDK入会的调用方式基本相同，新版新增了更多的选项，迁移过来比较容易。
```
void joinMeeting(JoinParam param)
```
具体接口函数格式请参考[TencentMeetingSDK（TMSDK）接口参考文档](../Common/TencentMeetingSDK（TMSDK）接口参考文档.md)

## 6. 打开会前主页

在旧版SDK中，通过调用`ForwardHome()`来显示会前的主页，而在新版SDK中是通过调用`PreMeetingService.showPreMeetingView()`来实现。


## 6. 错误码
旧版SDK各端错误码有部分不相同，新版各端统一一套错误码。

具体请参考[TencentMeetingSDK（TMSDK）接口参考文档](../Common/TencentMeetingSDK（TMSDK）接口参考文档.md)