# 环境要求
- macOS版本不低于 macOS 11.0
- Xcode版本不低于 Xcode 13.0
- CocoaPods 版本不低于 1.10.0
- Node.js 版本不低于 14.0（仅运行Electron Sample需要）
- npm 版本不低于 6.0（仅运行Electron Sample需要）

# SDK包目录结构

## 解压SDK包

首先下载并解压 `TMSDK_MacOS_XXX.tar.gz` 压缩包到本地任意目录：
```bash
# 解压命令示例
tar -xzf TMSDK_MacOS_XXX.tar.gz
```

## 目录结构说明

解压后的目录结构如下所示（目录名称会根据实际版本号有所不同）：
```
${SDK_ROOT}/
├── SDK
│   └── TMSDK.framework              # 通用二进制SDK (包含 x86_64 和 arm64)
├── SDKSample
│   ├── Mac                          # 原生 macOS Sample工程
│   └── Electron                     # Electron Sample工程
└── tmsdk-node-addon                 # Node.js Native Addon（Electron专用）
    ├── binding.gyp                  # Node Addon 构建配置
    ├── src/                         # Addon 源代码
    └── package.json                 # 依赖配置
```

**环境变量说明**：以下步骤中 `${SDK_ROOT}` 表示 SDK 包解压后的根目录路径，请根据实际解压路径替换。

# 运行说明

SDK提供了两种Sample运行方式：
1. **原生Sample** - 使用 Xcode 开发的 macOS 原生应用
2. **Electron Sample** - 基于 Electron 框架的跨平台应用

## 1. 运行原生Sample

### 运行步骤

1. 安装CocoaPods依赖

   进入 Mac Sample 工程目录并安装依赖：
   ```bash
   cd ${SDK_ROOT}/SDKSample/Mac
   pod install
   ```

2. 打开并运行项目

   使用 Xcode 打开工作空间：
   ```bash
   open ${SDK_ROOT}/SDKSample/Mac/SDKSample.xcworkspace
   ```
   
   在 Xcode 中：
   - 点击 Run 按钮（⌘R）启动项目

3. 运行结果

   项目启动后，将显示 SDK Sample 主界面，你可以在此界面中体验腾讯会议 SDK 的各项功能。

### 原生Sample工程结构说明
```
SDKSample/Mac/
├── SDKSample.xcworkspace            # Xcode工作空间文件
├── Podfile                          # CocoaPods依赖配置
├── Podfile.lock                     # CocoaPods依赖锁定文件
├── Pods                             # CocoaPods依赖库
└── SDKSample                        # Sample应用主工程
    ├── SDKSample.xcodeproj          # Xcode工程文件
    └── SDKSample                    # 源码和资源文件目录
        ├── AppDelegate.h            # 应用代理头文件
        ├── AppDelegate.m            # 应用代理实现
        ├── ViewController.h         # 视图控制器头文件
        ├── ViewController.m         # 视图控制器实现
        ├── Main.storyboard          # 故事板文件
        ├── Assets.xcassets          # 资源文件
        └── Info.plist               # 应用配置文件
```

---

## 2. 运行Electron Sample

### 运行步骤

1. 拆分 SDK 架构

   **为什么要拆分？**

   SDK 提供的 `TMSDK.framework` 是一个通用二进制文件，同时包含 x86_64（Intel 芯片）和 arm64（Apple 芯片）两种架构。拆分的原因包括：

   - 📦 减小打包体积（拆分后只需包含目标架构的文件）
   - 🚀 提升应用启动速度
   - 🎯 按需打包对应架构

   **执行拆分命令：**

   ```bash
   # 进入 SDK 目录
   cd ${SDK_ROOT}/SDK

   # 执行拆分脚本
   ./mac_split_framework
   ```

   **拆分结果：**

   ```
   SDK/
   ├── TMSDK.framework          # 原通用二进制文件
   ├── x64/                     # x86_64 架构（Intel 芯片）
   │   └── TMSDK.framework
   └── arm64/                   # arm64 架构（Apple 芯片）
       └── TMSDK.framework
   ```

2. 安装 Node.js Addon 依赖

   SDK 通过 Node.js Native Addon 与 Electron 进行通信，需要先编译安装：

   ```bash
   # 进入 Node Addon 目录
   cd ${SDK_ROOT}/tmsdk-node-addon

   # 安装依赖并编译
   npm install
   ```

   > 💡 此步骤会编译生成 `wemeet_electron_sdk.node` 文件，这是 SDK 的核心桥接模块

3. 安装 Sample 依赖

   ```bash
   # 进入 Sample 工程目录
   cd ${SDK_ROOT}/SDKSample/Electron

   # 安装依赖
   npm install
   ```

4. 启动 Sample

   ```bash
   # 启动 Electron 应用
   npm run start:mac
   ```

   > 🎉 应用启动后，您将看到 SDK Sample 主界面，可以体验会议的完整流程

### Electron Sample工程结构说明
```
SDKSample/Electron/
├── package.json                    # 项目配置和依赖
├── main.js                         # Electron 主进程
├── renderer.js                     # 渲染进程（SDK调用封装）
├── index.html                      # 用户界面
└── node_modules/                   # npm依赖包
```