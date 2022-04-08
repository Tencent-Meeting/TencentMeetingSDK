# 1. SDK 调用的基本时序
1. 获取SDK实例
2. SDK初始化
    1. 调用`TMSDK.initialize`进行SDK初始化，并在参数中设置回调代理`SDKCallback`
    2. 响应SDK初始化回调`SDKCallback.onSDKInitializeResult`，**回调结果成功才表示初始化完成**
3. 登录
    1. 获取`AccountService`实例
    2. 设置回调代理`setAuthenticationCallback`
    3. 调用`AccountService.login`进行登录
    4. 响应登录回调`AuthenticationCallback.onLogin`，**回调结果成功表示登录成功**
4. 入会
    1. 获取`PreMeetingService`实例
    2. 设置回调代理`setPreMeetingCallback`
    3. 调用`PreMeetingService.joinMeeting`进行入会
    4. 响应入会回调`PreMeetingCallback.onJoinMeeting`，回调结果成功表示入会成功


# 2. 初始化相关

# 3. 登录相关


# 4. 入会相关



