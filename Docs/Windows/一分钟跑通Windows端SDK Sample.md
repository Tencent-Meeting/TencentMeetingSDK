# 环境要求
- Windows版本不低于 Windows 7（支持 32 位和 64 位）
- Visual Studio（仅运行原生Sample需要）
- Node.js 版本不低于 14.0（仅运行Electron Sample需要）
- npm 版本不低于 6.0（仅运行Electron Sample需要）

# SDK包目录结构

## 解压SDK包

首先下载并解压 `TMSDK_Windows_XXX.zip` 压缩包到本地任意目录

## 目录结构说明

解压后的目录结构如下所示（目录名称会根据实际版本号有所不同）：
```
${SDK_ROOT}/
├── SDK
│   └── x64/                         # SDK 核心库目录
│       ├── wemeet_base.dll          # SDK 基础库
│       ├── wemeetsdk_x86.dll        # SDK 主库（32位）
│       ├── wemeetsdk_x64.dll        # SDK 主库（64位）
│       └── Release/                 # SDK 资源文件
│
├── SDKSample
│   ├── Windows                      # 原生 Windows Sample工程
│   └── Electron                     # Electron Sample工程
│
└── tmsdk-node-addon                 # Node.js Native Addon（Electron专用）
    ├── binding.gyp                  # Node Addon 构建配置
    ├── src/                         # Addon 源代码
    ├── package.json                 # 依赖配置
    └── ...                          # 其他文件
```

**环境变量说明**：以下步骤中 `${SDK_ROOT}` 表示 SDK 包解压后的根目录路径，请根据实际解压路径替换。

# 运行说明

SDK提供了两种Sample运行方式：
1. **原生Sample** - 使用 Visual Studio 开发的 Windows 原生应用
2. **Electron Sample** - 基于 Electron 框架的跨平台应用

## 1. 运行原生Sample

### 运行步骤

1. 打开项目

   使用 Visual Studio 打开解决方案Win32Sample.sln

2. 运行项目

   - 点击 “开始执行（不调试）” 按钮或选择“本地Windows调试器”启动项目

3. 运行结果

   项目启动后，将显示 SDK Sample 主界面，你可以在此界面中体验腾讯会议 SDK 的基础功能。

### 原生Sample工程结构说明
```
SDKSample/Windows/Win32Sample/
├── Win32Sample.sln                   # Visual Studio 解决方案文件
├── Win32Sample.vcxproj               # 项目文件
├── Win32Sample.vcxproj.filters       # 项目筛选器
├── Win32Sample.cpp                   # 主程序入口
├── Resource.h                        # 资源头文件
├── Win32Sample.rc                    # 资源文件
├── tmsdk_*_view.h                    # 示例 UI 视图
└── x64/                              # 64位编译输出目录
```

---

## 2. 运行Electron Sample

### 运行步骤

1. 安装 Python

   **为什么要安装 Python？**

   Windows 下编译 Node.js Native Addon（用于生成 `wemeet_electron_sdk.node`）通常依赖 `node-gyp` 工具链，而 `node-gyp` 在构建过程中需要 Python 参与执行构建脚本。

   - 📦 为 `node-gyp` 提供构建脚本运行环境
   - 🚀 保障 `npm install` 过程中原生模块可以正常编译

   **版本要求：**Python 版本 **>= 3.6.0**

   **官方下载：**`https://www.python.org/downloads/windows/`

2. 编译 Node.js Addon

   SDK 通过 Node.js Native Addon 与 Electron 进行通信，需要先编译生成 `wemeet_electron_sdk.node` 文件：
   **执行编译命令：**

   ```bash
   # 进入 Node Addon 目录
   cd ${SDK_ROOT}/tmsdk-node-addon

   # 安装依赖并编译
   npm install
   ```
   > 💡 此步骤会编译生成 `wemeet_electron_sdk.node` 文件，这是 SDK 的核心桥接模块

3. 安装 Electron Sample 依赖

   ```bash
   # 确保在 Sample 工程目录
   cd ${SDK_ROOT}/SDKSample/Electron

   # 安装依赖
   npm install
   ```

4. 启动 Electron Sample

   ```bash
   # 启动 Electron 应用
   npm run start:win
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