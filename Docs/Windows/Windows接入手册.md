- # SAASSDK接入手册-Windows
  
  ## 1. Windows SDK 集成接入指南
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
  ### 2.1 JWT简介
  鉴权和登录流程都使用[JWT](https://jwt.io/)  标准协议（ RFC 7519）
  <font color=red>注：使用1.3.1 中申请的 SDK Key 以及 SDK Secret!!</font>
  JWT包含三部分：

  1. Header（头部）
  1. Payload（负载）
  1. Signature（签名）
  - **Header**
    alg属性表示签名的算法（algorithm），默认是HMAC SHA256（写成HS256）。typ属性表示这个令牌（token）的类型（type），JWT令牌统一写为JWT
  ```json 
  {
  "alg": "HS256",
  "typ": "JWT"
  }
  ```
<font color=red> 注意：需要明确下来签名算法!!</font>
  将上面的JSON对象使用 Base64URL 算法（详见后文）转成字符串

  - **Payload**
  ```json 
  {
  "aud": "Tencent Meeting", // 受众
  "exp": 1590804000, // 过期时间
  "iat": 1588212000, // 签发时间
  "iss": "sdk_key", // 申请到的 sdk_key
  "sub": "1234567890" // 用户唯一标识 uid
  }
  ```
<font color=red> 注意：Header 和 Payload 是明文。不要在这两个元素中存储机密信息。!!</font>
  将上面的JSON对象使用 Base64URL 算法（详见后文）转成字符串

  - **Signature**
    用第一步中申请sdk 分配的 sdksecret ，使用 Header 里面指定的签名算法，按照下面的公式产生 Signature 。
  ``` json
  HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  sdksecret)
  ```
  算出Signature 以后，把 Header 、 Payload 、 Signature 三个部分拼成一个字符串，每个部分之间用 点 ""（（..）分隔 sdk_token 生成。
  ### 2.2 生成sdk_token鉴权
  SDK Token用于调用 SDK 时的机构身份识别，使用 JWT 实现。由业务服务端生成sdk_token ，提供给业务客户端初始化 SDK 时传入。
 <font color=red> 注：为保证您的应用安全性，请在服务器端存储密钥并且生成Token ，请使用 1.3.1 中申请的 sdkkey 以及 sdksecret。!!</font>

  #### 2.2.1 服务端生成sdk_token
  根据服务器端所用语言，如未引入过，请在JWT 上查找对应 JWT 签名（至少支持HS256 ）所需依赖库并引入，以 JAVA 为例，在 maven 引入依赖：
  ``` Java
  <dependency>
  <groupId>com.nimbusds</groupId>
  <artifactId>nimbus-jose-jwt</artifactId>
  <version>4.11.2</version>
  </dependency>
  ```
  然后实例化您的签名类：
  ``` Java
  class TokenProvider {
      protected final RSASSASigner signer;
      public final JWSHeader header;
      public TokenProvider(byte[] sharedSecret) {
      // 读取 secret并创建签名实例
      this.signer = new RSASSASigner(sharedSecret);
      this.header = new JWSHeader.Builder(JWSAlgorithm.HS256).type(JOSEObjectType.JWT).build();
      }
  }
  ```
  该类给下一节的接口提供签名方法。
  #### 2.2.3 服务端提供 sdk_token 生成接口
  服务器端提供Token 生成接口，当接口收到客户端请求时，封装信息，调用上一节的签名实例 假设为 provider 获得 Token ，返回给客户端。
  生成的sdk_token 样例如下：
  ``` json
  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJUZW5jZW50IE1lZXRpbmciLCJleHAiOjE1OTA4MDQwMDAsImlhdCI6MTU4ODIxMjAwMCwiaXNzIjoic2RrX2tleSIsInN1YiI6IjEyMzQ1Njc4OTAifQ.lTj3fSAit9hyTrlnnlb5sJx0oK3F8XtuJnPzKEcD3xg
  ```
  #### 2.2.3 客户端消费 sdk_token
  初始化SDK 时，需先从服务端获取 sdk_token ，并将其传入 SDK 初始化上下文内，见3.1 初始化 sdk 。
  ### 2.3 生成 id_token 登录
  id_token用于 提供可信的机构用户身份给腾讯会议。
<font color=red> 注：为保证您的应用安全性，请在服务器端存储密钥并且生成Token ，使用 idsecret。!!</font>

  #### 2.3.1 同2.2.1
  #### 2.3.2 同2.2.2
  #### 2.3.4 客户端消费 id_token
  提供接口给客户端 （与 2.2.3 区别在于标红部分）
  服务器端提供Token 生成接口，<font color=red>  不可接受匿名请求，可以获取当前用户的信息，!! 当接口收到客户端请求时，封装身份信息，调用上一节的签名实例 假设为 provider 获得 Token返回给客户端。</font>

  #### 2.3.4 客户端消费 id_token
  客户端在认证SDK 时，先调用上一节的接口获得 Token 后，请求腾讯会议身份管理服务换取授权码。此处可参考 demo 工程中 AuthCodeHelper.kt 内的实现。
  ## 3. Windows SDK API 接口文档
  接口说明可参考统一接口文档
```
## 3. Windows SDK 错误码对照表

错误码说明可参考统一接口文档

## 4. FAQ

- 出现以下错误，请按照前面的工程配置，检查 SDK 头文件的目录是否正确添加：
> fatal error C1083: Cannot open include file: 'wemeet_sdk.h': No such file or directory

- 出现以下错误，请按照前面的工程配置，检查 SDK 库目录和库文件是否正确添加：
> LINK : fatal error LNK1104: 无法打开文件“wemeetsdk.lib”
> error LNK2019: 无法解析的外部符号 __imp__GetWemeetSDKInstance，该符号在函数 "protected: virtual int __thiscall CDemoDlg::OnInitDialog(void)" (?OnInitDialog@CDemoDlg@@MAEHXZ) 中被引用

- 出现以下错误，请按照前面的工程配置，检查 SDK 的 DLL 是否拷贝到执行目录：
    ![ 'image.png'](./res/4.png)

- 应用异常退出后，切换账号登录异常或者登录的账号信息错误
> 如果登录的账号发生切换，请主动调用登出接口以清空登录态，再重新尝试登录。
  
- 出现以下错误，请更改字符集为“使用多字节字符集”：
> C2664	“void IPreMeetingService::ShowMeetingDetailView(const char *,const char *)”: 无法将参数 1 从“wchar_t *”转换为“const char *”
