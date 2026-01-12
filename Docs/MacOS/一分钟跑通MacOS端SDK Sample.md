# 环境要求
- macOS版本不低于 macOS 11.0
- Xcode版本不低于 Xcode 13.0
- CocoaPods 版本不低于 1.10.0

# 运行步骤

1. 解压SDK包后基本目录结构如下所示

   首先下载并解压 TMSDK_MacOS_XXX.tar.gz 压缩包到本地任意目录：
   ```bash
   # 解压命令示例
   tar -xzf TMSDK_MacOS_XXX.tar.gz
   ```

   解压后的目录结构如下所示（目录名称会根据实际版本号有所不同）：
   ```
   ${ROOT}/
   ├── SDK
   │   └── TMSDK.framework              # 通用二进制SDK (包含 x86_64 和 arm64)
   └── SDKSample
       └── Mac                          # macOS Sample工程
   ```

   **环境变量说明**：以下步骤中 `${ROOT}` 表示 SDK 包解压后的根目录路径，请根据实际解压路径替换。

2. 安装CocoaPods依赖

   进入 Mac Sample 工程目录并安装依赖：
   ```bash
   cd ${ROOT}/SDKSample/Mac
   pod install
   ```

3. 打开并运行项目

   使用 Xcode 打开工作空间：
   ```bash
   open ${ROOT}/SDKSample/Mac/SDKSample.xcworkspace
   ```
   
   在 Xcode 中：
   - 点击 Run 按钮（⌘R）启动项目

4. 运行结果

   项目启动后，将显示 SDK Sample 主界面，你可以在此界面中体验腾讯会议 SDK 的各项功能。

# SDK Sample工程结构说明
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