# FAQ

### TypeScript中是用wemeet sdk
1. 项目中引入node-loader
2. 添加配置
```javascript
{
    test: /\.node$/,
    loader: 'node-loader'
}
```
    注意检查是否和其它配置冲突
  
3. npm install 或者 yarn install
4. 将TMSDK.framework拷贝至./node_modules/electron/dist/Electron.app/Contents/Frameworks/   (可以通过自定义脚本实现，参考electron demo)
6. import * as wemeet_sdk from 'wemeet_electron_sdk.node的目录'
7. 调用sdk函数，如wemeet_sdk.GetSDKVersion()

---

Q. 接入腾讯会议 SDK 后，在 macOS 上使用 Electron >= 39.1.2 版本，在会议窗口（Qt 窗口）中按下系统快捷键（如 Cmd+C/V/Z/A 等）导致应用崩溃（EXC_BAD_ACCESS）

A：根本原因是Electron 39.1.2 基于 Chromium 142，该版本的安全补丁扩大了 performKeyEquivalent: 的拦截范围。当应用菜单中存在带 accelerator（快捷键）的菜单项时，Chromium 会拦截所有 NSWindow 的键盘事件（包括 SDK 的 Qt 窗口），与 Qt 5.x 的 QCocoaEventDispatcher 产生 NSEvent 双重释放，最终导致 EXC_BAD_ACCESS 崩溃。建议的解决方案是动态切换应用菜单，在 main.js 的 app.on('ready', ...) 中，根据 Electron BrowserWindow 的焦点状态动态切换菜单：
- BrowserWindow 获得焦点时：设置带 accelerator 的完整菜单，支持 Cmd+C/V/Z/A 等快捷键
- BrowserWindow 失去焦点时（Qt 窗口激活）：切换为不带 accelerator 的菜单，阻断 Chromium 的 performKeyEquivalent: 对 Qt 窗口键盘事件的拦截
