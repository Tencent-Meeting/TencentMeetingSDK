# Flutter 接入手册

> 📖 本文档将指导您如何在 Flutter 项目中快速接入腾讯会议 SDK（Linux 版本）
>
> ⚠️ **本文档以 Ubuntu 24.04+（x86_64）为例**，其他 Linux 发行版或架构的用户在接入时可能需要根据实际情况做适当调整（如系统依赖的安装命令、库路径等）。

## 📋 目录

- [环境要求](#环境要求)
- [SDK 目录结构](#sdk-目录结构)
- [SDK 接入指南](#sdk-接入指南)
- [接口说明](#接口说明)
- [回调说明](#回调说明)

## 环境要求

- **系统要求**：Ubuntu（x86_64）
- **开发环境**：
  - Flutter SDK
  - CMake
  - GTK（`libgtk-3-dev`）
  - Clang
  - Ninja

## SDK 目录结构

### Linux SDK 包结构

```
${SDK_ROOT}/
├── SDK/                          # SDK 核心文件
│   ├── libwemeetsdk.so           # SDK 主库
│   ├── libwemeet_base.so         # SDK 基础库
│   ├── Release/                  # SDK 资源文件
│   └── include/                  # SDK 头文件
│
└── Flutter_Demo/                 # Flutter Sample 示例工程
    ├── lib/                      # Dart 源代码
    │   ├── main.dart             # 应用入口
    │   ├── wemeet_sdk_bindings.dart   # FFI 绑定层（SDK 开发者提供）
    │   ├── wemeet_sdk_types.dart      # FFI 类型定义（SDK 开发者提供）
    │   ├── sdk_callback_manager.dart  # 回调管理器（示例参考，接入方可自行实现）
    ├── linux/                    # Linux 平台代码
    │   ├── CMakeLists.txt        # 构建配置
    │   ├── wemeet_sdk_wrapper.cc # C Wrapper 层（SDK 开发者提供）
    │   └── wemeet_sdk_wrapper.h  # C Wrapper 头文件（SDK 开发者提供）
    ├── run_x86_64.sh             # 启动脚本
    ├── pubspec.yaml              # 项目依赖配置
    └── ...
```

> 📝 **`${SDK_ROOT}`** 表示腾讯会议 SDK 的根目录，即下载解压后的 SDK 包的顶级目录，在执行命令时，请将 `${SDK_ROOT}` 替换为实际的 SDK 根目录路径。

## SDK 接入指南

### 步骤 1：准备工作

1. **申请 SDK 凭证**
   - 联系腾讯会议商务获取 SDK ID 和 SDK Secret
   - 配置好安全凭证后方可正常使用 SDK

2. **安装系统依赖**

```bash
sudo apt install libgtk-3-dev clang ninja-build cmake pkg-config
```

3. **创建 Flutter 项目**

```bash
# 创建项目目录
flutter create my_meeting_app
cd my_meeting_app
```

### 步骤 2：拷贝 SDK 文件

**目录布局要求**：将 `${SDK_ROOT}/SDK` 目录放置在 Flutter 项目的**同级目录**下（与 `my_meeting_app` 平级）：

```
<your-workspace>/
├── SDK/                 # 从 ${SDK_ROOT}/SDK 拷贝而来
└── my_meeting_app/
    └── ...
```

### 步骤 3：拷贝 SDK 开发者提供的文件

SDK 开发者已提供以下文件，接入方**无需自行实现**，直接拷贝使用即可：

#### 3.1 拷贝 C Wrapper 层（Linux 平台代码）

将以下文件拷贝到您项目的 `linux/` 目录下：

| 文件 | 说明 |
|------|------|
| `wemeet_sdk_wrapper.cc` | C Wrapper 实现，封装 C++ SDK 为 C 接口供 Dart FFI 调用 |
| `wemeet_sdk_wrapper.h` | C Wrapper 头文件，定义所有 C 接口 |

```bash
cp ${SDK_ROOT}/Flutter_Demo/linux/wemeet_sdk_wrapper.cc my_meeting_app/linux/
cp ${SDK_ROOT}/Flutter_Demo/linux/wemeet_sdk_wrapper.h  my_meeting_app/linux/
```

#### 3.2 拷贝 Dart FFI 绑定层

将以下文件拷贝到您项目的 `lib/` 目录下：

| 文件 | 说明 |
|------|------|
| `wemeet_sdk_bindings.dart` | FFI 绑定层，封装所有 C 接口调用 |
| `wemeet_sdk_types.dart` | FFI 类型定义，包含结构体和回调类型 |

```bash
cp ${SDK_ROOT}/Flutter_Demo/lib/wemeet_sdk_bindings.dart my_meeting_app/lib/
cp ${SDK_ROOT}/Flutter_Demo/lib/wemeet_sdk_types.dart my_meeting_app/lib/
```

> 💡 **提示**：Demo 中的 `sdk_callback_manager.dart` 是回调管理的示例实现，接入方可参考其实现方式，根据自身业务需求自行编写回调管理逻辑。

### 步骤 4：配置 CMakeLists.txt

修改 `linux/CMakeLists.txt`，添加 SDK 库引用和 Wrapper 编译配置：

```cmake
# SDK 库路径配置（相对于 linux/ 目录的上两级）
set(SDK_LIB_DIR "${CMAKE_SOURCE_DIR}/../../SDK")
set(SDK_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/../../SDK/include")

# 添加 SDK 头文件目录
include_directories("${SDK_INCLUDE_DIR}")

# 引入 SDK 共享库
add_library(wemeetsdk SHARED IMPORTED)
set_target_properties(wemeetsdk PROPERTIES
  IMPORTED_LOCATION "${SDK_LIB_DIR}/libwemeetsdk.so"
)

add_library(wemeetbase SHARED IMPORTED)
set_target_properties(wemeetbase PROPERTIES
  IMPORTED_LOCATION "${SDK_LIB_DIR}/libwemeet_base.so"
)

# 编译 C Wrapper 为共享库
add_library(wemeet_sdk_wrapper SHARED
  "wemeet_sdk_wrapper.cc"
)

# 设置 rpath，使 wrapper 能找到 SDK 库
set_target_properties(wemeet_sdk_wrapper PROPERTIES
  BUILD_RPATH "${SDK_LIB_DIR}"
  INSTALL_RPATH "$ORIGIN"
)

# 链接 SDK 库
target_link_libraries(wemeet_sdk_wrapper PRIVATE
  wemeetsdk
  wemeetbase
)

# 安装 Wrapper 库到 bundle/lib 目录
install(TARGETS wemeet_sdk_wrapper LIBRARY DESTINATION "${INSTALL_BUNDLE_LIB_DIR}" COMPONENT Runtime)

# 安装 SDK 库和资源文件到 bundle/lib 目录
install(FILES "${SDK_LIB_DIR}/libwemeetsdk.so"    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}" COMPONENT Runtime)
install(FILES "${SDK_LIB_DIR}/libwemeet_base.so"  DESTINATION "${INSTALL_BUNDLE_LIB_DIR}" COMPONENT Runtime)
install(DIRECTORY "${SDK_LIB_DIR}/Release"
  DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime
  USE_SOURCE_PERMISSIONS
)
```

### 步骤 5：配置 pubspec.yaml

在 `pubspec.yaml` 中添加 `ffi` 依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  ffi: ^2.0.0
  path: ^1.8.0
```

然后执行：

```bash
flutter pub get
```

### 步骤 6：创建主入口与界面文件

创建 `main.dart`，完成 FFI 桥接库加载、回调注册以及用户交互界面。该文件包含以下核心流程：

1. **加载 FFI 桥接库**：调用 `WemeetSDKBindings.initialize()` 加载 `libwemeet_sdk_wrapper.so`
2. **获取 SDK 实例**：调用 `WemeetSDKBindings.getInstance()` 获取单例
3. **注册回调**：通过 `WemeetSDKBindings.setXxxCallback()` 注册各类异步回调
4. **调用 SDK 接口**：初始化、登录、入会等操作

```dart
import 'dart:ffi' as ffi;
import 'package:flutter/material.dart';
import 'wemeet_sdk_bindings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 第一步：加载 FFI 桥接库 libwemeet_sdk_wrapper.so
  WemeetSDKBindings.initialize();

  // 第二步：获取 SDK 实例
  WemeetSDKBindings.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '腾讯会议 SDK 示例应用',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _sdkIdController = TextEditingController(text: '');
  final _sdkTokenController = TextEditingController(text: '');
  final _ssoUrlController = TextEditingController(text: '');
  String _status = 'SDK 未初始化';

  @override
  void initState() {
    super.initState();
    // 注册 SDK 回调（必须在调用 SDK 接口之前完成）
    _registerCallbacks();
  }

  /// 注册所有 SDK 回调
  void _registerCallbacks() {
    // 初始化回调
    WemeetSDKBindings.setInitializeCallback((code, msg) {
      debugPrint('Initialize result: code=$code, msg=$msg');
      setState(() {
        _status = code == 0 ? 'SDK 初始化成功' : '初始化失败: $msg';
      });
    });

    // 反初始化回调
    WemeetSDKBindings.setUninitailzeCallback((code, msg) {
      debugPrint('Uninitialize result: code=$code, msg=$msg');
      setState(() {
        _status = code == 0 ? 'SDK 已反初始化' : '反初始化失败: $msg';
      });
    });

    // 登录回调
    WemeetSDKBindings.setLoginCallback((code, msg) {
      debugPrint('Login result: code=$code, msg=$msg');
      setState(() => _status = code == 0 ? '登录成功' : '登录失败: $msg');
    });

    // 登出回调
    WemeetSDKBindings.setLogoutCallback((type, code, msg) {
      debugPrint('Logout result: type=$type, code=$code, msg=$msg');
      setState(() => _status = code == 0 ? '已登出' : '登出失败: $msg');
    });

    // 入会回调
    WemeetSDKBindings.setJoinMeetingCallback((code, msg, meetingCode) {
      debugPrint('JoinMeeting result: code=$code, msg=$msg, meetingCode=$meetingCode');
      setState(() => _status = code == 0 ? '已入会: $meetingCode' : '入会失败: $msg');
    });
    // 更多回调可按需注册，详见回调说明章节
  }

  // 初始化 SDK
  void _initSDK() {
    // 只需传入必需参数，可选参数（appName、appIcon、language、proxyInfo）均有默认值
    final params = WemeetSDKBindings.createInitParams(
      sdkId: _sdkIdController.text,
      sdkToken: _sdkTokenController.text,
      dataPath: '/tmp/wemeet_data',
    );
    WemeetSDKBindings.initializeSDK(params, ffi.nullptr);
    WemeetSDKBindings.freeInitParams(params);
    setState(() => _status = '正在初始化...');
  }

  // 反初始化 SDK
  void _uninitSDK() {
    WemeetSDKBindings.uninitializeSDK();
    setState(() => _status = '正在反初始化...');
  }

  // 登录
  void _login() {
    WemeetSDKBindings.login(_ssoUrlController.text);
  }

  // 登出
  void _logout() {
    WemeetSDKBindings.logout();
  }

  // 快速会议
  void _quickMeeting() {
    WemeetSDKBindings.quickMeeting();
  }

  // 离开会议
  void _leaveMeeting() {
    WemeetSDKBindings.leaveMeeting(1);
  }

  // 显示会前界面
  void _showPreMeetingView() {
    WemeetSDKBindings.showPreMeetingView(0);
  }

  @override
  void dispose() {
    // 清除所有回调，防止内存泄漏
    WemeetSDKBindings.clearInitializeCallback();
    WemeetSDKBindings.clearUninitializeCallback();
    WemeetSDKBindings.clearLoginCallback();
    WemeetSDKBindings.clearLogoutCallback();
    WemeetSDKBindings.clearJoinMeetingCallback();
    WemeetSDKBindings.clearPreMeetingActionResultCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('腾讯会议 SDK 示例应用')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态显示
            Text('状态: $_status', style: const TextStyle(fontSize: 16)),
            const Divider(),

            // SDK 初始化
            const Text('SDK 初始化', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _sdkIdController, decoration: const InputDecoration(labelText: 'SDK ID', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _sdkTokenController, decoration: const InputDecoration(labelText: 'SDK Token', border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(onPressed: _initSDK, child: const Text('初始化 SDK')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _uninitSDK, child: const Text('反初始化')),
            ]),
            const Divider(),

            // 账户服务
            const Text('账户服务', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _ssoUrlController, decoration: const InputDecoration(labelText: 'SSO URL', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(onPressed: _login, child: const Text('登录')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _logout, child: const Text('登出')),
            ]),
            const Divider(),

            // 会议功能
            const Text('会议功能', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 10, runSpacing: 10, children: [
              ElevatedButton(onPressed: _quickMeeting, child: const Text('快速会议')),
              ElevatedButton(onPressed: _leaveMeeting, child: const Text('结束会议')),
              ElevatedButton(onPressed: _showPreMeetingView, child: const Text('显示会前界面')),
            ]),
          ],
        ),
      ),
    );
  }
}
```

> 💡 界面说明：
> - **SDK 初始化**：输入您的 SDK ID 和 SDK Token，点击"初始化 SDK"按钮
> - **账户服务**：输入 SSO URL 进行登录/登出操作
> - **会议功能**：提供快速会议、结束会议、显示会前界面等功能按钮

### 步骤 7：构建应用

```bash
# 构建 Release 版本
flutter build linux --release
```

构建产物位于：

```
my_meeting_app/build/linux/x64/release/bundle/
├── my_meeting_app               # 可执行文件
├── lib/
│   ├── libwemeet_sdk_wrapper.so # C Wrapper 库
│   ├── libwemeetsdk.so          # SDK 主库
│   ├── libwemeet_base.so        # SDK 基础库
│   └── Release/                 # SDK 资源文件
└── data/                        # Flutter 资源
```

### 步骤 8：运行应用

SDK 包中提供了启动脚本 `run_x86_64.sh`，该脚本会自动处理库路径设置和 Wayland 兼容性问题。

1. **拷贝启动脚本到项目根目录**：

```bash
cp ${SDK_ROOT}/Flutter_Demo/run_x86_64.sh my_meeting_app/
```

2. **修改脚本中的可执行文件名**：

将脚本中的 `wemeet_flutter_demo` 替换为您的项目名称 `my_meeting_app`：

```bash
cd my_meeting_app
sed -i 's/wemeet_flutter_demo/my_meeting_app/g' run_x86_64.sh
```

3. **运行应用**：

```bash
chmod +x run_x86_64.sh
./run_x86_64.sh
```

### 步骤 9：项目目录结构

完成上述步骤后，您的项目目录结构应如下：

```
<your-workspace>/
├── SDK/                              # 从 ${SDK_ROOT}/SDK 拷贝而来
│   ├── libwemeetsdk.so
│   ├── libwemeet_base.so
│   ├── Release/
│   └── include/
└── my_meeting_app/
    ├── lib/
    │   ├── main.dart
    │   ├── wemeet_sdk_bindings.dart
    │   ├── wemeet_sdk_types.dart     
    ├── linux/
    │   ├── CMakeLists.txt
    │   ├── wemeet_sdk_wrapper.cc
    │   └── wemeet_sdk_wrapper.h
    ├── pubspec.yaml
    └── ...
```

## 接口说明

> ⚠️ **注意**：SDK 接口分为异步接口和同步接口。异步接口的结果需要在对应的回调中处理，同步接口会直接返回结果。**初始化（`WemeetSDKBindings.initializeSDK`）必须等到 `onInitializeResult` 回调成功后，再进行其他接口调用**，否则其他接口调用均无效。

📖 本文档只列出接口的名称和参数，具体参数说明可以参考《TencentMeetingSDK（TMSDK）接口参考文档》

所有接口均通过 `WemeetSDKBindings` 类（Dart）调用。

### 4.1 SDK 生命周期

#### 加载 FFI 桥接库

```dart
WemeetSDKBindings.initialize()
```

说明：加载 FFI 桥接库 `libwemeet_sdk_wrapper.so`，必须在所有其他接口调用之前执行。

#### 获取 SDK 实例

```dart
WemeetSDKBindings.getInstance()
```

说明：获取 SDK 单例实例，需在 `initialize()` 之后调用。

#### 初始化 SDK

```dart
// 只需传入必需参数即可完成初始化
final params = WemeetSDKBindings.createInitParams(
  sdkId: sdkId,           // 必需
  sdkToken: sdkToken,     // 必需
  dataPath: dataPath,     // 必需
);

WemeetSDKBindings.initializeSDK(params, ffi.nullptr);

// 使用完毕后释放内存
WemeetSDKBindings.freeInitParams(params);
```

`createInitParams` 参数说明：

| 参数 | 是否必需 | 默认值 | 说明 |
|------|---------|--------|------|
| `sdkId` | ✅ 必需 | — | SDK ID |
| `sdkToken` | ✅ 必需 | — | SDK Token |
| `dataPath` | ✅ 必需 | — | SDK 数据存储路径 |
| `appName` | 可选 | `''` | 应用名称 |
| `appIcon` | 可选 | `''` | 应用图标路径 |
| `language` | 可选 | `'zh-CN'` | 语言设置 |
| `proxyInfo` | 可选 | `''` | 代理信息 |

说明：异步接口，结果通过 `onSDKInitializeResult` 回调返回。

#### 反初始化 SDK

```dart
WemeetSDKBindings.uninitializeSDK()
```

说明：异步接口，结果通过 `onSDKUninitializeResult` 回调返回。

#### 释放 SDK 实例

```dart
WemeetSDKBindings.releaseInstance()
```

说明：释放 SDK 实例，应在应用退出时调用。

### 4.2 账户服务

#### 登录

```dart
WemeetSDKBindings.login(ssoUrl)
```

说明：异步接口，结果通过 `onLogin` 回调返回。

#### 登出

```dart
WemeetSDKBindings.logout()
```

说明：异步接口，结果通过 `onLogout` 回调返回。

### 4.3 会前服务

#### 加入会议（通过参数）

```dart
final params = WemeetSDKBindings.createJoinParams(
  meeting_code: meetingCode,
  user_display_name: displayName,
  password: password,
);
WemeetSDKBindings.joinMeeting(params);
```

说明：异步接口，结果通过 `onJoinMeeting` 回调返回。

#### 加入会议（通过 JSON）

```dart
WemeetSDKBindings.joinMeetingByJson(jsonParam)
```

说明：`jsonParam` 为 JSON 格式字符串，格式可参考《TencentMeetingSDK（TMSDK）接口参考文档》。

#### 快速会议

```dart
WemeetSDKBindings.quickMeeting()
```

说明：异步接口，结果通过 `onJoinMeeting` 回调返回（与加入会议共用同一回调）。

#### 显示会前界面

```dart
WemeetSDKBindings.showPreMeetingView(style)
```
说明：结果通过 `onActionResult` 回调返回。

#### 显示上传日志界面

```dart
WemeetSDKBindings.showUploadLogsView()
```

说明：结果通过 `onActionResult` 回调返回。

#### 开启邀请用户回调

```dart
WemeetSDKBindings.enableInviteCallback(enable, show)
```

#### 开启会议信息回调

```dart
WemeetSDKBindings.enableMeetingInfoCallback(enable)
```

### 4.4 会中服务

#### 退出会议

```dart
WemeetSDKBindings.leaveMeeting(leaveMeetingType)
```

说明：异步接口，结果通过 `onLeaveMeeting` 回调返回。

#### 添加人员

```dart
WemeetSDKBindings.addUsersWithParam(jsonParam)
```

说明：`jsonParam` 为 JSON 格式字符串，结果通过 `onAddUsersResult` 回调返回。

> ⚠️ **注意**：目前 Flutter 仅支持**会中**添加会议成员。

#### 获取当前会议信息

```dart
final String info = WemeetSDKBindings.getCurrentMeetingInfo()
```

说明：同步接口，返回 JSON 格式字符串。

#### 获取会中窗口信息

```dart
final String info = WemeetSDKBindings.getMeetingWindowInfo()
```

说明：同步接口，返回 JSON 格式字符串。

#### 开启自定义组织架构

```dart
WemeetSDKBindings.enableCustomOrgInfo(enable)
```

#### 设置自定义组织架构信息

```dart
WemeetSDKBindings.setCustomOrgInfo(jsonParam)
```

说明：`jsonParam` 为 JSON 格式字符串，结果通过 `onActionResult` 回调返回，`action_type` 参数对应的枚举值为1000。

### 4.5 日志服务

#### 打开日志目录

```dart
WemeetSDKBindings.openLogDirectory()
```

#### 收集日志文件（同步）

```dart
final String result = WemeetSDKBindings.collectLogs(startTime, endTime)
```

说明：同步接口，`startTime`、`endTime` 为时间戳字符串（单位秒）。

#### 主动上传日志（异步）

```dart
WemeetSDKBindings.activeUploadLogs(beginTime, endTime, description)
```

说明：异步接口，`beginTime`、`endTime` 为时间戳（单位秒），`description` 为描述字符串，结果通过 `onActiveUploadLogsResult` 回调返回。

## 回调说明

### 回调机制

SDK 的所有异步接口结果均通过回调函数返回。接入方通过 `WemeetSDKBindings.setXxxCallback()` 注册各类回调，通过 `WemeetSDKBindings.clearXxxCallback()` 清除回调。

> 💡 **提示**：Demo 中的 `sdk_callback_manager.dart` 提供了一个基于 Listener 模式的回调管理示例，接入方可参考其实现方式，也可以直接使用 `WemeetSDKBindings` 的回调注册方法。

### 注册回调

```dart
@override
void initState() {
  super.initState();
  // 注册初始化回调
  WemeetSDKBindings.setInitializeCallback((code, msg) {
    final success = code == 0;
    debugPrint('Initialize result: code=$code, msg=$msg');
    // 处理业务逻辑...
  });

  // 注册登录回调
  WemeetSDKBindings.setLoginCallback((code, msg) { /* ... */ });

  // 注册其他回调...
}

@override
void dispose() {
  // 清除所有回调，防止内存泄漏
  WemeetSDKBindings.clearInitializeCallback();
  WemeetSDKBindings.clearLoginCallback();
  // 清除其他回调...
  super.dispose();
}
```

### 回调注册/清除方法汇总

| 回调类型 | 注册方法 | 清除方法 |
|---------|---------|--------|
| SDK 初始化 | `setInitializeCallback` | `clearInitializeCallback` |
| SDK 反初始化 | `setUninitailzeCallback` | `clearUninitializeCallback` |
| 登录 | `setLoginCallback` | `clearLoginCallback` |
| 登出 | `setLogoutCallback` | `clearLogoutCallback` |
| 入会 | `setJoinMeetingCallback` | `clearJoinMeetingCallback` |
| 离会 | `setLeaveMeetingCallback` | `clearLeaveMeetingCallback` |
| 邀请入会 | `setInviteMeetingCallback` | `clearInviteMeetingCallback` |
| 添加成员 | `setOnAddUsersResultCallback` | `clearAddUsersCallback` |
| 显示会议信息 | `setShowMeetingInfoCallback` | `clearShowMeetingInfoCallback` |
| 查询组织架构 | `setQueryCustomOrgInfoCallback` | `clearQueryCustomInfoCallback` |
| 会前操作结果 | `setPreMeetingActionResultCallback` | `clearPreMeetingActionResultCallback` |
| 会中操作结果 | `setInMeetingActionResultCallback` | `clearInMeetingActionResultCallback` |
| 打开日志目录 | `setOpenLogDirectoryCallback` | `clearOpenLogDirectoryCallback` |
| 主动上传日志 | `setActiveUploadLogsCallback` | `clearActiveUploadLogsCallback` |
