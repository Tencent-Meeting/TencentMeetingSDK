
# 1. 简介
每位接入腾讯会议SDK的客户，将拥有独有的安全凭证，对通信过程进行验证。所以，客户在技术接入前，请联系腾讯会议对接人进行信息登记，并申请相关的秘钥等信息。

## 1.1 准备工作
1. 通过腾讯会议对接人获取：`SDK ID`和`SDK Secret`，用于后续生成`SDK Token`签名之用，并在SDK初始化时传入。
2. 客户生成RSA私钥和公钥，私钥成为`ID Secret`，用于后续生成`ID Token`签名之用，公钥提交到腾讯会议，用于验证`ID Token`。
3. 确认SSO登录URL的子域名名称，并获得`SSO URL`地址

## 1.2 什么是SDK Token
客户（机构）的安全凭证，通过SDK ID（别名`SDK Key`）和SDK Secret生成，来验证SDK的使用者所属的机构，是客户（机构）的唯一标识凭证。

## 1.3 什么是ID Token
对客户下的使用者账户进行认证的安全凭证，每个登录的用户都需要通过ID Secret的私钥来生成不同的ID Token，从而进行身份验证。

**注意：** 为保证您的应用安全性，请将秘钥信息（包括但不限于SDK ID、SDK Secret、ID Secret）及企业身份信息部署到您的Sever端，不可由终端程序持有保管。


# 2. 流程说明

## 2.1 整体总流程概述
1. 客户的终端启动时，向客户的服务端请求SDK Token，服务端通过SDK ID和SDK Secret生成SDK Token返回给终端
2. 客户的终端调用SDK初始化接口，将SDK Token设置进去，完成初始化流程
3. 客户的终端通过自己协议完成登录，获取当前用户信息（该流程与腾讯会议无关）
4. 客户的终端向客户的服务端请求获取当前用户的ID Token和SSO URL，服务端通过ID Secret和当前用户信息生成ID Token返回给终端
5. 客户的终端调用SDK登录接口，如果没有之前已登录的有效信息，SDK会回调客户的终端程序，在回调中将SSO URL和ID Token拼接成完整URL设置进来，完成登录。

## 2.2 初始化流程
![SDK Initialize Flow](images/image-1623296733287.png)

**关键流程说明**：
1. 客户的Client端通过自有的协议向客户自己的Server端请求获取sdk_id和sdk_token数据，该流程属于客户自身业务实现，与腾讯会议无关。
2. 客户的Server端持有申请到的SDK ID和SDK Secret，生成对应sdk_token数据，具体生成方法见下文的`SDK Token生成说明`。
3. 客户的Server端在生成token时，需用SDK Secret来做签名。
4. 客户的Client端获取到sdk_id和sdk_token后，即可调用腾讯会议SDK的初始化函数，返回初始化结果。

**<span style="color:red">注意</span>**：
- SDK Token应由Server端来生成，Client端`不可以`持有SDK Secret来生成Token，否则`存在安全风险`
- SDK Token不包含用户的账户信息，因此客户端切换账户时，可以不用更新SDK Token，并可以在SDK Token有效期内本地缓存SDK Token。
- SDK Token有效期为使用SDK的有效周期，过期后，即使已经登录了，SDK也将无法使用，并会踢出登录，SDK也提供了相应接口更新SDK Token。


## 2.3 登录流程
![SDK Login Flow](images/image-1623298049225.png)

**关键流程说明**：
1. 客户的Client端请求自己业务上的账户登录。
2. 客户端Server端登录验证成功，返回账户信息给Client端，`以上两步为客户自身的业务逻辑`，与腾讯会议无关。
3. 客户的Client端此时需向客户的Server端请求包含ID Token（简写id_token）的SSO URL，用于登录的身份认证，`该功能属于客户自身业务接口`，与腾讯会议无关。
4. 客户的Server端根据请求用户的信息，并通过持有的ID Secret生成id_token，并拼接成SSO URL，具体生成方法见下文的`ID Token生成说明`。
5. 客户的Client端从Server端获取到SSO URL。
6. 客户的Client端调用腾讯会议SDK的`Login(SSO_URL)`方法，请求登录身份认证。
7. 腾讯会议SDK访问带有id_token参数信息的SSO URL，从IDaaS服务方获取Authorization Code。
8. 腾讯会议SDK将获得的Authorization Code以及SDK Token发给腾讯会议Server端请求登录验证，登录结果将返回给SDK。
9. 当身份认证成功后，SDK会向Client端发起`OnLogin`的回调，完成登录。

**<span style="color:red">注意</span>**：
- ID Token应由Server端来生成，Client端`不可以`持有ID Secret来生成Token，否则`存在安全风险`**
- ID Token有效期仅在登录时验证，如果过期，将不能进行登录。已登录后不受影响。

# 3. SDK Token生成说明

SDK Token 按照`JWT Token规范`实现，用于调用 SDK 时的机构身份识别。

由`客户的Server端`生成，提供给客户的Client端用来初始化 SDK 时传入。

关于`JWT`相关知识点，可参考文末的`附录：JWT简介`


## 3.1 SDK Token的格式
SDK Token是JWT的格式，其各个部分定义如下：

### Header
```
{
  "alg": "HS256",
  "typ": "JWT"
}
```
以上部分为固定值，按照上面写死即可。签名算法是SHA256。


### Payload
```
{
  "aud": "Tencent Meeting",	// 受众，固定写死为"Tencent Meeting"
  "exp": 1590804000,		// Token过期时间，由客户自己决定（单位：秒）
  "iat": 1588212000, 		// Token签发生成时间（当前时间，单位：秒）
  "iss": "2012081666" 		// 申请到的SDK ID
}
```
数据Payload部分包含以上四个属性，按要求填写即可。
所有涉及到时间的属性，都是Unix时间戳，即从1970年1月1日（UTC/GMT的午夜）开始所经过的秒数，不考虑闰秒。

**<span style="color:red">注意</span>**：
- SDK Token表示该企业在会议使用的授权，跟该企业下的用户账号无关，所以上面`exp`过期时间的时长最好远大于客户端一般使用的时长，
- 避免用户在使用过程中sdk_token过期而无法使用。经验建议值：15-30天。如果使用过程中，SDK Token过期，会有回调接口通知给客户，如果正好在会议中过期，则会退会并退出登录。

具体请参考[TencentMeetingSDK（TMSDK）接口参考文档](../Common/TencentMeetingSDK（TMSDK）接口参考文档.md)


### Signature
客户的Server端通过上文申请到的SDK Secret作为签名的secret，对整个数据进行SHA256签名。

## 3.2 示例
假设某客户的信息如下：
| 数据项 | 数值 |
| :--- | :--- |
| SDK ID | 2012081666 |
| SDK Secret | ZR8ztBMyoCX74DnSYyLUDdhE0sQ5ufxqad6w |

那么，客户的Server端需要生成的Header和Payload的JSON原始数据如上节所描述（不包含JSON中的注释）。
最终，SDK token：`eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJUZW5jZW50IE1lZXRpbmciLCJleHAiOjE1OTA4MDQwMDAsImlhdCI6MTU4ODIxMjAwMCwiaXNzIjoiMjAxMjA4MTY2NiJ9.wwatJAaGDfLvus65Ndwg_xhmvEki3Xn7hAP4A7AVDv8`




# 4. ID Token生成说明

SDK Token 按照`JWT Token规范`实现，当客户是通过OpenID Connect（OIDC）协议跟IDaaS服务方进行认证接入时，ID Token用于在用户登录时做身份认证使用。

由`客户的Server端`生成，提供给Client端用于用户登录身份验证使用。

>OIDC 是基于 OAuth 2.0 的可互操作的身份验证协议，作为一个开放授权标准，它允许用户让第三方应用访问该用户在某服务的特定私有资源但是不提供账号密码信息给第三方应用。OIDC 是目前对开发者最友好的身份认证协议之一，让开发者更加轻松地进行集成。

关于`JWT`相关知识点，可参考文末的`附录：JWT简介`


## 4.1 ID Token的格式
ID Token是JWT的格式，其各部分定义如下：

### Header
```
{
  "typ": "JWT",
  "alg": "RS256"
}
```
以上字段都是固定值，其中alg字段是RS256，表示用RSA签名。


### Payload
```
{
  "sub": "123456789",		//IDaaS系统中的username字段，对应腾讯会议的userId字段
  "iss": "2012081666",		//SDK ID
  "name": "tencent_dev04",	//IDaaS系统中的displayName字段，对应腾讯会议的username字段，即显示名称
  "exp": 1619554966,		//Token过期时间（单位：秒）
  "iat": 1601387166 		//Token签发生成时间（当前时间，单位：秒）
}
```
数据Payload部分包含以上五个属性，按要求填写即可。
所有涉及到时间的属性，都是Unix时间戳，即从1970年1月1日（UTC/GMT的午夜）开始所经过的秒数，不考虑闰秒。

如果过期，需再次请求id_token并重新登录。

### Signature
客户与IDaaS服务方约定生成的ID Secret，此处客户的Server端使用该ID Secret对整个数据进行签名，RSA签名方式。


# 附录：JWT简介
在`初始化`和`登录流程`中涉及到的Token都使用了 [JWT](https://jwt.io/) 标准协议（[RFC 7519](https://tools.ietf.org/html/rfc7519)），因此这章节对JWT做简单介绍，如已了解可跳过。

JWT包含三部分，通过点号`.`分割为：
1. Header（头部）
2. Payload（数据装载）
3. Signature（签名）

形式：`Header.Payload.Signature`

![JWT TOKEN](images/image-1608629054399.png)

## Header
头部的值是JSON字符串通过Base64URL编码得来。该JSON对象主要包含以下字段：
```
{
  "typ": "JWT",
  "alg": "HS256"
}
```
* typ表示令牌类型（type）：JWT 令牌统一写为JWT
* alg表示签名算法（algorithm）：默认为HS256

| alg值 | 签名算法 | 
| ------ | ------ |
| HS256 | HMAC SHA256 |
| RS256 | RSA |



## Payload
数据装载部分的值是JSON字符串通过Base64URL编码得来。该JSON对象用来存放实际需要传输的数据。
JWT为该JSON对象预定义了一些官方的字段，推荐给使用者，但不是强制：
- iss (issuer)：签发人
- exp (expiration time)：过期时间
- sub (subject)：主题
- aud (audience)：受众
- nbf (Not Before)：生效时间
- iat (Issued At)：签发时间
- jti (JWT ID)：编号

除了官方预定义字段外，使用者也可以自定义字段，例如：
```
{
  "sub": "1234567890",
  "name": "John Doe",
  "admin": true
}
```
**注意：** Header和Payload是明文。不要在这两部分中存储机密信息。

## Signature
签名部分的值是对上面Header和Payload两个部分签名得来的，为了防止数据被篡改。

签名算法由Header域的alg属性值决定。

针对 HMAC SHA256，签名方式：
```
HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload),  secret)
```


## 工具与资源
在JWT官网提供了编解码签名验证工具和SDK资源：https://jwt.io

### JWT编解码和签名验证工具

在JWT官网中，可以使用在线Debugger工具用于编解码和签名验证
![JWT Tools](images/image-1616231041777.png)

### JWT SDK库
JWT针对各种语言提供了开源的SDK开发库，`服务端生成Token时候会使用到`

SDK库支持的常见语言：
* .NET
* Python
* Node.js
* Java
* JavaScript
* Perl
* Ruby
* Erlang
* Go
* Groovy
* Rust
* Lua
* Objective-C
* Swift
* C\C++
* Delphi
* PHP
* Kotlin

