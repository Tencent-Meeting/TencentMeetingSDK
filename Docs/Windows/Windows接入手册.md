 # Windows SDK接入手册
  
  ## 1. 集成接入指南
  ### 1.1 版本环境提示
  - 本指南适用的 SDK 版本： v2.18.0.0
  - 支持 win7 及其以上的系统

  ### 1.2 SDK组成
  - demo
  - SDK
  SDK解压之后，打开文件夹，包含以下几个部分：

  | 目录名             | 说明                      |
  | ------------------ | ------------------------- |
  | Include            | SDK 接口头文件             |
  | Release            |  SDK依赖的资源文件和库文件 |
  | wemeet_base.dll、wemeetsdk_x86.dll | 32位App 依赖的库文件 |
  |wemeet_base_x64.dll、wemeetsdk_x64.dll | 64位App 依赖的库文件 |

  ### 1.3 集成步骤
  #### 1.3.1 申请你的 SDK Key & SDK Secret
  为了让SDK 正常使用，需要为 SDK 配置独有的安全凭证，安全凭证包括 SDK Key 和SDK Secret ，对每一次请求进行验证。联系腾讯会议商务对接人进行信息登记进行 SDK Key & SDK Secret 申请，包含以下信息：
 
 | 属性     | 填值     |
  | -------- | -------- |
  | 应用名称 | 必填     |
  | 平台类型 | Windows  |
  | 签名信息 | 必填     |
  | 备注信息 | （选填） |

  申请通过后，系统将为应用生成对应SDK Key & SDK Secret 提供客户，用于生成 SDK Token 并在 SDK 初始化时进行合法性验证，生成规则见 2.1。

  <font color=red> 注意：为保证您的应用安全性，请将认证相关信息（包括但不限于SDK Key 、 SDKSecret 、 appId ）及企业个人身份信息部署到您的 Sever 端进行获取。!!</font>
  
  #### 1.3.2 配置visual studio
  建议使用Visual Studio 2015 ，其他 Visual Studio 未经过严格测试。
  ##### 1.3.2.1 拷贝SDK
  工程建立完之后，将SDK 解压到工程目录下，并命名为 WemeetSDK。
  ##### 1.3.2.2 配置 SDK 头文件路径
  ![enter image description here](./res/3.2.png)
  ##### 1.3.2.3 配置 SDK 库文件路径
  ![enter image description here](./res/3.3.png)
  ##### 1.3.2.4 配置 SDK 库依赖
  ![enter image description here](./res/3.4.png)
  ##### 1.3.5 拷贝运行时依赖文件
  编译完成启动前需要将SDK相关库文件和资源文件拷贝到工程可执行文件的目录下
  32位App接入
  1. wemeetsdk_x86.dll、wemeet_base.dll
  2. Release文件夹下的所有文件：WemeetSDK\Release

  64位App接入
  1. wemeetsdk_x64.dll、wemeet_base_x64.dll
  2. Release文件夹下的所有文件：WemeetSDK\Release
  #### 1.3.3 SDK快速集成
  开发者按照以下步骤集成 SDK ，更详细步骤可参考 DEMO。

  ##### 1.3.3.1 导入 SDK 头文件
  ``` shell
  #include "wemeet_sdk.h"
  ```
  ##### 1.3.3.2 初始化 SDK
  ``` C++
  InitParams params;
  params.sdk_id = "sdk_id";
  params.sdk_token = "sdk_token";
  params.data_path = sdk_path.c_str(); // 【必填】日志和配置保存目录，需要utf-8编码
  params.app_name = ""; //品牌名称
  params.app_icon = ""; //工具栏图标路径，需要utf-8编码
  GetWemeetSDKInstance()->Initialize(params,this)
  ```
  ##### 1.3.3.3 设置回调
  目前会议提供四个回调：
  1. 登录授权的回调
  1. 会议相关的回调
  1. 会中分享的回调
  1. 会中信息的回调

  开发者可以继承实现自己关心的回调。
``` C++
class ISDKCallback {
public:
virtual ~ISDKCallback() {}
virtual void OnSDKInitializeResult(int code, const char* msg) = 0;
virtual void OnSDKTokenExpired(const char* sdk_token) = 0;
virtual void OnSDKError(int code, const char* msg) = 0;
};
class IAuthenticationCallback {
public:
virtual ~IAuthenticationCallback() {}
virtual void OnLogin(int code, const char* msg) = 0;
virtual void OnLogout(int type, int code, const char* msg) = 0;
};
class IPreMeetingCallback {
public:
virtual ~IPreMeetingCallback() {}
virtual void OnJoinMeeting(int code, const char* msg, const char* meeting_code) = 0;
};
class IInMeetingCallback {
public:
virtual ~IInMeetingCallback() {}
virtual void OnLeaveMeeting(int type, int code, const char* msg, const char* meeting_code) = 0;
virtual void OnInviteMeeting(const char* invite_info) = 0;
virtual void OnShowMeetingInfo(const char* meeting_info) = 0;
};
//通过如下接口设置回调。
GetWemeetSDKInstance()->GetAccountService()->SetCallback(this);
GetWemeetSDKInstance()->GetPreMeetingService()->SetCallback(this);
GetWemeetSDKInstance()->GetInMeetingService()->SetCallback(this);
```
  ##### 1.3.3.4 调用登录接口
  ``` C++
  GetWemeetSDKInstance()->GetAccountService()->Login(url.GetBuffer(0));
  ```

  ##### 1.3.3.5 调用登出接口
  调用登出接口后，SDK 内部会清空授权信息。
  ``` C++
  GetWemeetSDKInstance()->GetAccountService()->Logout();
  ```
  ##### 1.3.3.6 调用入会接口

  ```C++
  JoinMeetingParams params;
  params.meeting_code = ""; //【必填】会议号
  params.user_display_name = ""; //入会昵称，如果空则使用登录账号的昵称
  params.password = ""; //入会密码
  params.invite_url = ""; //如果为空显示腾讯会议的邀请链接
  params.face_beauty_on = true; //是否入会开启美颜
  params.mic_on = true; //是否入会开启麦克风
  params.camera_on = ""; //是否入会开启摄像头
  GetWemeetSDKInstance()->GetPreMeetingService()->JoinMeeting(param);
  ```

  ##### 1.3.3.7 设置投屏

  ```C++
  GetWemeetSDKInstance()->GetPreMeetingService()->ShowScreenCastView();
  ```
  ## 2.鉴权与登录
 详情请参考[《SDK鉴权与登录说明》](../Common/SDK鉴权与登录说明.md)


  ## 3. Windows SDK API 接口文档
  接口和错误码说明，可参考统一的[《TencentMeetingSDK（TMSDK）接口参考文档》](../Common/TencentMeetingSDK（TMSDK）接口参考文档.md)

