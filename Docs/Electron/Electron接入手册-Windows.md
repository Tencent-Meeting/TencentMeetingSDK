# Electron 接入手册

> 📖 本文档将指导您如何在 Electron 项目中快速接入腾讯会议 SDK（Windows 版本）

## 📋 目录

- [环境要求](#环境要求)
- [SDK 目录结构](#sdk-目录结构)
- [SDK 接入指南](#sdk-接入指南)
- [接口说明](#接口说明)
- [回调说明](#回调说明)

## 环境要求
- **系统要求**：Windows版本不低于 Windows 7（支持 32 位和 64 位）
- **开发环境**：
  - Node.js 14.0+
  - Npm 6.0+

## SDK 目录结构
### Windows SDK 包结构

```
${SDK_ROOT}/
├── SDK/                          # SDK 核心文件
│   └── x64/                      # SDK 核心库目录
│       ├── wemeet_base.dll       # SDK 基础库
│       ├── wemeetsdk_x86.dll     # SDK 主库（32位）
│       ├── wemeetsdk_x64.dll     # SDK 主库（64位）
│       └── Release/              # SDK 资源文件
│
├── SDKSample/                    # Sample 示例工程
│   └── Electron/                 # Electron Sample
│       ├── package.json          # 依赖配置
│       ├── src/                  # 源代码
│       └── ...                   # More files
│
└── tmsdk-node-addon/             # Node.js Native Addon
    ├── binding.gyp               # Node Addon 构建配置
    ├── src/                      # Addon 源代码
    ├── package.json              # 依赖配置
    └── ...                       # More files
```
> 📝 **`${SDK_ROOT}`** 表示腾讯会议 SDK 的根目录，即下载解压后的 SDK 包的顶级目录，在执行命令时，请将 `${SDK_ROOT}` 替换为实际的 SDK 根目录路径。

## SDK 接入指南

### 步骤 1：准备工作

1. **申请 SDK 凭证**
- 联系腾讯会议商务获取 SDK ID 和 SDK Secret
- 配置好安全凭证后方可正常使用 SDK

2. **创建 Electron 项目**

```bash
# 创建项目目录
mkdir my-meeting-app
cd my-meeting-app

# 初始化项目
npm init -y

# 安装 Electron
npm install --save-dev electron
```

### 步骤 2：拷贝 SDK Node Addon、${SDK_ROOT}/SDK   

1. 将编译好的 `TMSDK.node` 文件拷贝到项目根目录：

> 📌 编译 `TMSDK.node` 的教程请查看：《一分钟跑通Windows端SDK Sample》中的 `2. 运行Electron Sample`。

> 💡 `TMSDK.node` 是 SDK 的 Node.js Native Addon 模块，提供了与 Electron 的桥接功能

2. 将 `${SDK_ROOT}/SDK` 目录拷贝到 `my-meeting-app` **同级目录**下（与 `my-meeting-app` 平级）：

```
<your-workspace>/
├── SDK/                 # 从 ${SDK_ROOT}/SDK 拷贝而来
└── my-meeting-app/
    ├── TMSDK.node
    └── ...
```

### 步骤 3：配置启动脚本

在 package.json 中配置启动脚本：

```json
{
  "name": "my-meeting-app",
  "version": "1.0.0",
  "main": "main.js",
  "scripts": {
    "start": "electron ."
  }
}
```

### 步骤 4：在主进程中设置 DLL 搜索路径

创建 main.js，在 `main.js` 引入 `TMSDK.node` 前，先设置 SDK DLL 的搜索路径：

```javascript
const { app, BrowserWindow, ipcMain } = require('electron')
const path = require('path')

// 设置 DLL 搜索路径
const sdkDllPath = path.join(__dirname,'../', 'SDK', 'x64')
process.env.PATH = `${sdkDllPath};${process.env.PATH}`

```

### 步骤 5：配置主进程加载 SDK

在主进程中加载 SDK 并设置 IPC 通信：

```javascript
// 导入腾讯会议 SDK 的 Node.js 原生模块
const wemeet_sdk = require(path.join(__dirname, 'TMSDK.node'))

let mainWindow

function setupIPC() {
  // 设置 SDK 的 JavaScript 回调函数，用于接收 SDK 的事件通知
  wemeet_sdk.AddJsCallback((result) => {
    if (mainWindow) {
      // 将 SDK 的回调结果发送到渲染进程
      mainWindow.webContents.send('sdk:callback', result)
    }
  })

  // 处理 SDK 初始化请求
  ipcMain.handle('sdk:init', async (event, sdkId, sdkToken) => {
    const dataPath = path.join(__dirname, 'sdk_data')
    wemeet_sdk.InitWemeetSDK(sdkId, sdkToken, dataPath, 'MyMeetingApp', '', 'zh-CN', '', 'true')
  })

  // 处理 SDK 反初始化请求
  ipcMain.handle('sdk:uninit', () => {
    wemeet_sdk.UninitWemeetSDK(JSON.stringify({}))
  })

  // 处理登录请求
  ipcMain.handle('sdk:login', (event, ssoUrl) => {
    wemeet_sdk.Login(ssoUrl)
  })

  // 处理登出请求
  ipcMain.handle('sdk:logout', () => {
    wemeet_sdk.Logout()
  })

  // 处理快速入会请求
  ipcMain.handle('sdk:quickMeeting', () => {
    wemeet_sdk.QuickMeeting()
  })

  // 处理离开会议请求
  ipcMain.handle('sdk:leaveMeeting', () => {
    wemeet_sdk.LeaveMeeting(1)
  })

  // 处理显示会前界面请求
  ipcMain.handle('sdk:showPreMeetingView', () => {
    wemeet_sdk.ShowPreMeetingView('0', '0')
  })
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  })
  mainWindow.loadFile('index.html')
}

app.whenReady().then(() => {
  setupIPC()
  createWindow()
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow()
  }
})
```

### 步骤 6：配置渲染进程

创建 renderer.js，通过 IPC 与主进程通信：

```javascript
// 渲染进程SDK调用代码
const { ipcRenderer } = require('electron')

// 监听SDK回调事件，接收并显示SDK返回的结果
ipcRenderer.on('sdk:callback', (event, result) => {
    const data = JSON.parse(result)
    alert(`${JSON.stringify(data)}`)
})

// 通用IPC调用包装函数
async function invokeSDK(channel, ...args) {
    ipcRenderer.invoke(channel, ...args)
}

// 初始化SDK
function initSDK() {
    const sdkId = document.getElementById('sdkId').value.trim()
    const sdkToken = document.getElementById('sdkToken').value.trim()
    invokeSDK('sdk:init', sdkId, sdkToken)
}

// 反初始化SDK
function uninitSDK() {
    invokeSDK('sdk:uninit')
}

// 登录
function login() {
    const ssoUrl = document.getElementById('ssoUrl').value.trim()
    invokeSDK('sdk:login', ssoUrl)
}

// 登出
function logout() {
    invokeSDK('sdk:logout')
}

// 快速入会
function quickMeeting() {
    invokeSDK('sdk:quickMeeting')
}

// 离开会议
function leaveMeeting() {
    invokeSDK('sdk:leaveMeeting')
}

// 显示会前界面
function showPreMeetingView() {
    invokeSDK('sdk:showPreMeetingView')
}
```

### 步骤 7：创建界面文件

创建 index.html，提供用户交互界面：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>腾讯会议 SDK 示例应用</title>
</head>
<body>
    <h1>腾讯会议 SDK 示例应用</h1>
    <hr>

    <h2>SDK 初始化</h2>
    <p>SDK ID: <input type="text" id="sdkId" value="" style="width: 300px;"></p>
    <p>SDK Token: <textarea id="sdkToken" style="width: 600px; height: 60px;"></textarea></p>
    <button onclick="initSDK()">初始化 SDK</button>
    <button onclick="uninitSDK()">反初始化</button>
    <hr>

    <h2>账户服务</h2>
    <p>SSO URL: <input type="text" id="ssoUrl" value="" style="width: 800px;"></p>
    <button onclick="login()">登录</button>
    <button onclick="logout()">登出</button>
    <hr>

    <h2>会议功能</h2>
    <button onclick="quickMeeting()">快速会议</button>
    <button onclick="leaveMeeting()">结束会议</button>
    <button onclick="showPreMeetingView()">显示会前界面</button>

    <script src="renderer.js"></script>
</body>
</html>
```

> 💡 界面说明：
> - **SDK 初始化**：输入您的 SDK ID 和 SDK Token，点击"初始化 SDK"按钮
> - **账户服务**：输入 SSO URL 进行登录/登出操作
> - **会议功能**：提供快速会议、结束会议、显示会前界面等功能按钮

### 步骤 8：项目目录结构

完成上述步骤后，您的项目目录结构应该如下：

```
<your-workspace>/
├── SDK/                      # 从 ${SDK_ROOT}/SDK 拷贝而来
└── my-meeting-app/
    ├── TMSDK.node            
    ├── main.js               # 主进程文件
    ├── renderer.js           # 渲染进程文件
    ├── index.html            # 界面文件
    ├── package.json          # 项目配置
    ├── node_modules/         # 依赖模块
    └── ...
```

### 步骤 9：启动应用

```bash
# 安装依赖
npm install

# 启动应用
npm start
```

## 接口说明

> ⚠️ 注意：接口调用是异步过程，需要在对应的回调中处理接口调用的结果，其中**InitWemeetSDK**初始化的操作必须要等到该接口的回调之后再进行其他的接口调用，否则其他的接口调用都是无效的

📖 本文档只列出接口的名称和参数，具体参数说明可以参考《TencentMeetingSDK（TMSDK）接口参考文档》

### 3.1 TMSDK 成员函数

#### 获取当前SDK版本号

```javascript
wemeet_sdk.GetSDKVersion()
```
说明：返回string类型，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 初始化 SDK

```javascript
wemeet_sdk.InitWemeetSDK(sdk_id, sdk_token, data_path, app_name, app_icon, language, proxy_info, allow_home_view)
```

说明：
- >= 3.6.3版本：新增 `language` 语言设置可选项
- >= 3.12.1版本：需要传 `app_icon` 参数，Windows端支持自定义应用图标
- 具体参数说明可参考《TencentMeetingSDK（TMSDK）接口参考文档》

#### 反初始化SDK

```javascript
wemeet_sdk.UninitWemeetSDK(uninit_json)
```

说明：>= 3.12版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 检查初始化状态

```javascript
wemeet_sdk.IsInitialized()
```

说明: 异步接口，调用InitWemeetSDK，接收到初始化成功回调后，返回true，没接收初始化成功回调前返回false，3.0.107加入。

#### 刷新sdk_token

```javascript
wemeet_sdk.RefreshSDKToken(sdk_token)
```

说明：同步接口，参数是要刷新的sdk_token串。返回类型int，失败返回错误码，成功返回0。

#### 获取当前sdk_token

```javascript
wemeet_sdk.GetCurrentSDKToken()
```

说明：同步接口，返回类型string，返回当前sdk登录使用的sdk_token串。3.0.107加入。

#### 打开日志目录

```javascript
wemeet_sdk.OpenLogDirectory()
```

#### 收集日志信息

```javascript
wemeet_sdk.CollectLogFiles(begin_time, end_time)
```

说明：>= 3.12版本，begin_time、end_time为string类型，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 上传日志

```javascript
wemeet_sdk.ActiveUploadLogs(begin_time, end_time, description)
```

说明：>= 3.21.100版本，begin_time、end_time为string类型，description为string类型，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 设置代理

```javascript
wemeet_sdk.SetProxyInfo(proxy_info)
```

说明：参数proxy_info为json格式的string类型，格式可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 获取代理

```javascript
wemeet_sdk.GetProxyInfo()
```

说明：返回值参考SetProxyInfo。

#### 一键跳转指定页面

```javascript
wemeet_sdk.HandleSchema(schema_url)
```

说明：参数schema_url为跳转链接，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 添加人员操作，接入方可以邀请人加入预定会议、或邀请人员加入会议

```javascript
wemeet_sdk.AddUsersWithParam(json_param)
```

说明：>= 3.6.401版本，json_param为json格式字符串，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 短链入会解析

```javascript
wemeet_sdk.ParseMeetingInfoUrl(scheme_url)
```

说明：>= 3.12版本，scheme_url为string类型，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

### 3.2 AccountService 成员函数

#### 登录

```javascript
wemeet_sdk.Login(sso_url)
```

#### 通过json串登录

```javascript
wemeet_sdk.LoginByJSON(login_json)
```

说明：>= 3.24.100版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 登出

```javascript
wemeet_sdk.Logout()
```

#### 检查登录态

```javascript
wemeet_sdk.IsAuthorized()
```

说明: 异步接口，调用登录，接收到登录成功回调后，返回true，没接收登录成功回调前返回false。

#### 登录态跳转

```javascript
wemeet_sdk.JumpUrlWithLoginStatus(target_url)
```

#### 获取带登录态的url链接

```javascript
wemeet_sdk.GetUrlWithLoginStatus(url)
```

说明：同步接口，参数url为不带登录态的url，返回类型string，返回带登录态的url。

### 3.3 PreMeetingService 成员函数

#### 入会

```javascript
wemeet_sdk.JoinMeeting(meeting_code, user_display_name, password, invite_url, mic_on, camera_on, speaker_on, face_beauty_on)
```

#### 通过json串入会

```javascript
wemeet_sdk.JoinMeetingByJSON(meeting_josn)
```

说明：参数meeting_josn为json格式的string类型，格式可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 快速会议

```javascript
wemeet_sdk.QuickMeeting()
```

说明：>= 3.6.200版本。

#### 通过json串快速会议

```javascript
wemeet_sdk.QuickMeetingByJSON(json_param)
```

说明：>= 3.6.300版本，参数json_param为json格式的string类型，格式可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 显示SDK自带的会前界面（显示home界面）

```javascript
wemeet_sdk.ShowPreMeetingView()
```

显示home界面【即将移除】

```javascript
wemeet_sdk.GoToHomeView()
```

#### 显示会议历史

```javascript
wemeet_sdk.ShowHistoricalMeetingView()
```

#### 显示会议详情

```javascript
wemeet_sdk.ShowMeetingDetailView(meeting_id, current_sub_meeting_id)
```

说明：>= 3.6.200版本，重载ShowMeetingDetailView接口，入参可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》

```javascript
wemeet_sdk.ShowMeetingDetailView(meeting_id, current_sub_meeting_id, start_time, is_history)
```

#### 显示加入会议页面

```javascript
wemeet_sdk.ShowJoinMeetingView()
```

说明：展示加入会议页面。

#### 显示预定会议页面

```javascript
wemeet_sdk.ShowScheduleMeetingView(meeting_type)
```

说明：参数meeting_type为会议类型，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 显示上传日志界面

```javascript
wemeet_sdk.ShowUploadLogsView()
```

说明：>= 3.21.100版本，展示上传日志界面。

#### 显示设置管理界面

```javascript
wemeet_sdk.ShowMeetingSettingView()
```

说明：展示设置管理界面。

#### 显示投屏页面

```javascript
wemeet_sdk.ShowScreenCastView()
```

说明：展示投屏页面。

#### 超声波解码

```javascript
wemeet_sdk.DecodeUltrasoundScreenCastCode()
```

说明：>= 3.12.3版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 无线投屏

```javascript
wemeet_sdk.StartScreenCast(cast_param)
```

说明：cast_param为json格式字符串，详细可参考《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 查询会议信息

```javascript
wemeet_sdk.QueryMeetingInfo(meeting_info)
```

说明：>= 3.6.200版本，meeting_info为json格式字符串，详细可参考《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 查询本地录制信息

```javascript
wemeet_sdk.QueryLocalRecordInfo(meeting_id, period_id)
```

说明：>= 3.12版本，meeting_id、period_id为int类型，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 本地录制文件进行转码

```javascript
wemeet_sdk.Transcode(path_id)
```

说明：>= 3.12版本，path_id为int类型，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 打开会议本地录制文件所在文件夹

```javascript
wemeet_sdk.ShowRecordFolder(path_id)
```

说明：>= 3.12版本，path_id为int类型，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### SDK预定会议界面中，开启定制化通讯录的回调

```javascript
wemeet_sdk.EnableAddressBookCallback(enable, show)
```

说明：>= 3.6.401版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 设置是否显示SDK响铃邀请界面

```javascript
wemeet_sdk.EnableRingInvitationView(enable)
```

说明：>= 3.12.4版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 处理响铃邀请

```javascript
wemeet_sdk.HandleRingInvitation(accept, invite_id, callback)
```

说明：>= 3.12.4版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 获取近场投屏码

```javascript
wemeet_sdk.DiscoverNearScreenCastCode(json_param)
```

说明：>= 3.24.300版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

### 3.4 InMeetingService 成员函数

#### 退出会议

```javascript
wemeet_sdk.LeaveMeeting(leave_meeting_type)
```

说明：可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 邀请回调开关

```javascript
wemeet_sdk.SetNeedShareCallback(invite_on, invite_show)
```

说明：可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》enableInviteCallback说明。

#### 会议信息回调开关

```javascript
wemeet_sdk.SetNeedMeetingInfoCallback(info_on, info_show)
```

说明：可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》enableMeetingInfoCallback说明。

#### 设置是否使用添加成员的回调

```javascript
wemeet_sdk.EnableInviteUsersCallback(enable, show)
```

说明：>= 3.6.401版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 会中窗口置顶

```javascript
wemeet_sdk.BringInMeetingViewTop()
```

说明：桌面端：>= 3.0.102版本，如果当前没有会中窗口，则不做任何操作。没有回调。可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 获取当前会议状态信息

```javascript
wemeet_sdk.GetCurrentMeetingInfo()
```
说明：>= 3.6.300版本，返回string类型，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 设置是否开启自定义组织架构信息

```javascript
wemeet_sdk.EnableCustomOrgInfo(enable)
```

说明：>= 3.6.401版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 对相关成员设置自定义的组织架构信息

```javascript
wemeet_sdk.SetCustomOrgInfo(json_param)
```

说明：>= 3.6.401版本，json_param为json格式字符串，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 操作会中窗口，支持【全屏】和【退出全屏】

```javascript
wemeet_sdk.ManipulateWindow(action_param)
```

说明：>= 3.12.201版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 开关会议中字幕展示组件

```javascript
wemeet_sdk.SwitchCaption(open)
```

说明：>= 3.12.3版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》switchCaption(bool open, Callback complete)说明。

#### 更新字幕相关设置选项

```javascript
wemeet_sdk.UpdateCaptionSettings(json_setting)
```

说明：>= 3.12.3版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》updateCaptionSettings(string json_setting, Callback complete)说明。

#### 获取当前屏幕共享信息

```javascript
wemeet_sdk.GetScreenShareInfo()
```

说明：>= 3.12.3版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 获取会中窗口信息

```javascript
wemeet_sdk.GetMeetingWindowInfo()
```

说明：>= 3.12版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 用来设置共享屏幕入会后，结束共享时是否展示"结束共享"弹窗

```javascript
wemeet_sdk.SetLeaveCastRoomActionType(int actionType)
```

说明：>= 3.12.403版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 切换为会议的默认布局

```javascript
wemeet_sdk.SwitchLayout(layout_json)
```

说明：>= 3.12.404版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》switchLayout(string layout_json, Callback complete)说明。

#### 订阅/退订会中事件

```javascript
wemeet_sdk.SubscribeInMeetingActionEvent(action_type, subscribe, subscription_json)
```

说明：>= 3.12.404版本，可参考统一《TencentMeetingSDK（TMSDK）接口参考文档》说明。

#### 添加js回调

```javascript
wemeet_sdk.AddJsCallback(call_back)
```

说明：这个函数是electron的sdk独有的函数，call_back 是一个js的function，参数是一个json字符串

## 回调说明

### 回调机制

除 `GetSDKVersion`、`GetCurrentSDKToken`、`RefreshSDKToken`、`GetUrlWithLoginStatus` 等少数同步接口外，其他所有接口的调用都是通过异步回调返回。

### 回调格式

异步回调的返回值是一个标准的 JSON 字符串，格式如下：

| Key   | 类型   | 说明                                    |
| ----- | ------ | --------------------------------------- |
| func  | string | 回调对应的调用函数名称，回调的标识      |
| code  | int    | 回调错误码，0为正常                     |
| msg   | string | 详细的错误信息                          |
| param | string | 回调需要带回的数据，也是一个json object |

回调的具体类别和参数说明，请参考《TencentMeetingSDK（TMSDK）接口参考文档》
