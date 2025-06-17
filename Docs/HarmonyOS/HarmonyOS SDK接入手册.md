# 1. HarmonyOS SDK接入指南

## 1.1 SDK说明
### 1.1.1 版本环境说明
- 支持compatibleSdkVersion = 5.0.1(13)
- 使用DevEco Studio Build Version: 5.0.7.210 及以上版本作为IDE

### 1.1.2 SDK组成
- SDKSample Demo样例工程
- libs 包含所有SDK库文件的.har和.tgz文件夹

## 1.2 集成步骤

### 1.2.1 工程脚本配置
先将TMSDK_HarmonyOS.zip解压，然后将解压后的libs文件夹整体复制到鸿蒙工程根目录（ProjectDir）下，复制完成后的目录结构成如下形式：
```
ProjectDir/libs/*.har
ProjectDir/libs/*.tgz
```
#### 1.2.1.1 project配置文件

TMSDK的har包+hsp包(.tgz)文件，放在集成方工程根目录下的libs目录下，并在 ***ProjectDir/oh-package.json5***文件中增加overrides节点配置，配置如下：
```
"overrides": {
    "tm_harmony_sdk": "file: ./libs/tm_harmony_sdk.har",
    "tm_harmony_sdk_core": "file: ./libs/tm_harmony_sdk_core.har",
    "app_common": "file: ./libs/app_common.har",
    "common": "file: ./libs/common.har",
    "module_core": "file: ./libs/module_core.har",
    "nxui_app": "file: ./libs/nxui_app.har",
    "nxui_uikit": "file: ./libs/nxui_uikit.har",
    "startup": "file: ./libs/startup.har",
    "thirdparty": "file: ./libs/thirdparty.har",
    "wemeet": "file: ./libs/wemeet.har",
    "wemeet_framework": "file: ./libs/wemeet_framework.har",
    "wemeet_platform": "file: ./libs/wemeet_platform.har",
    "qimei": "file: ./libs/qimei-1.0.21.har",
    "wemeet_base": "file: ./libs/wemeet_base.tgz",
    "libxcast": "file: ./libs/libxcast.tgz"
  },
```

如果overrides节点已经存在，请在overrides节点内增加上述overrides中的配置项。

#### 1.2.1.2 module配置文件
在需要使用TencentMeetingSdk的模块中，引入相关依赖，配置到此模块的 ***module/oh-package.json5*** 文件中，配置如下：
```
  "dependencies": {
    "tm_harmony_sdk": "file: ../libs/tm_harmony_sdk.har",  //这里要看使用模块的实际路径
  }

```

#### 1.2.1.3 so架构与so打包冲突解决
在entry module的build-profile.json5文件中，配置abiFilters,配置如下：
```
{
  "apiType": "stageMode",
  "buildOption": {
      ...
    "externalNativeOptions": {
      ...
      //因为TencentMeetingSDK目前只支持arm64-v8a架构的设备，因此需做如下配置，过滤下cpu架构进行打包。
      "abiFilters": ["arm64-v8a"]
    },
    ...
    "nativeLib": {
      "filter": {
        "pickFirsts": [
      // 如果出现多个同名的so库冲突，请在这里指明pickFirst
          "libwemeet_platform.so",
          "libwemeet_framework.so",
          "libWMWhiteboardSDK.so",
          "libtms_canary.so",
          "libtms_file_delta.so",
          "libvideo_render.so",
          "libskia.so",
        ],
        "enableOverride": true,
        "excludes": [
          "armeabi-v7a/**",
          "x86_64/**"
        ]
      }
    }
  }
  ...
}

```

#### 1.2.1.4 compatibleSdkVersion配置
工程目录下的build-profile.json5文件中，compatibleSdkVersion必须大于等于TencentMeetingSDK当前的compatibleSdkVersion版本，否则无法使用，参考配置如下：
```project/build-profile.json5
...
"products": [
      {
            ...
            "compatibleSdkVersion": "5.0.1(13)",
      }
]
...
```
#### 1.2.1.5 targetSdkVersion配置
该配置为可选，建议不要设置。如果设置，请设置值等同于compatibleSdkVersion，否则可能导致应用无法打包上架。

### 1.2.2 安装依赖
项目根目录下执行如下安装命令:
```
ohpm install
```

### 1.2.3 代码配置

#### 1.2.3.1 appStage配置
* 在应用entry模块的ets/entry目录下创建App.ets文件，并做如下配置：
```
import { AbilityStage } from '@kit.AbilityKit'
import { TMSDK } from 'tm_harmony_sdk'

export class App extends AbilityStage {
  onCreate(): void {
    TMSDK.initOnApplicationCreate(this.context);
  }
}
```
* 在应用entry模块的module.json5配置文件中，增加如下声明：
```
  "module": {
    ...
    "srcEntry": "./ets/entry/App.ets",  //增加App.ets的配置
    ...
  }
```


该步骤主要用于设置AbilityStageContext以及必要的状态，不会进行真正的初始化。

#### 1.2.3.2 初始化函数
在鸿蒙平台，sdk的初始化函数需要额外传入common.UIAbilityContext作为参数。示例如下：
```
private context = getContext(this) as common.UIAbilityContext;
private init: () => void = () => {
      TMSDK.initialize(this.context, param, new MyCallback());
}
```

#### 1.2.3.2 保活配置：
在使用sdk的ability文件所在的module中，配置backgroundModes。
例如sdk_sample中的模块配置文件
sdk_sample/src/main/module.json5如下：
```
...
"abilities": [
      {
        "name": "Sdk_sampleAbility",
        ...
        "backgroundModes": [
          // 长时任务类型的配置项
          "voip",
          "audioRecording"
        ]
      }
]
...
```

### 1.2.4 路由使用说明
鸿蒙平台下，TencentMeetingSdk使用鸿蒙推荐的Navigation实现路由跳转。宿主与SDK进行路由跳转时，需要依赖**宿主提供NavPathStack**，也需要宿主在接口回调中处理SDK页面交互的路由事件。
- 在SDKCallback回调接口中，SDK提供了onRouterToPage函数和onTerminateSdkPage函数，分别用来处理进入SDK页面和退出SDK页面的路由事件。
```
onRouterToPage: (scheme: string, routerParam: string, pushPathHandler?: (scheme: string, params: string, stack?: NavPathStack, context?: common.UIAbilityContext) => boolean) => void;

onTerminateSdkPage: (scheme: string, routerParam?: string, popPathHandler?: (pathStack?: NavPathStack, context?: common.UIAbilityContext) => boolean) => void;
```
- 为方便快速接入，SDKCallback回调接口的onRouterToPage函数和onTerminateSdkPage函数参数中，分别提供了路由处理函数：pushPathHandler和popPathHandler。
```
pushPathHandler?: (scheme: string, params: string, stack?: NavPathStack, context?: common.UIAbilityContext) => boolean

popPathHandler?: (pathStack?: NavPathStack, context?: common.UIAbilityContext) => boolean
```
- 接入方只需在onRouterToPage函数中调用pushPathHandler，在onTerminateSdkPage函数中调用popPathHandler，即可自动处理SDK页面交互的路由事件。
- pushPathHandler和popPathHandler中都需要使用**宿主提供的NavPathStack**和**宿主提供的UIAbilityContext**作为参数



#### 1.2.4.1 方案一(快速接入，推荐)：

SDK的路由交互部分完全由TencentMeetingSdk提供的回调中的handler函数来完成。
宿主提供handler函数所需要的相关参数, 并执行handler。

sdk的onRouterToPage和onTerminateSdkPage回调函数中，宿主执行handler函数，并传入scheme、routerParam、NavPathStack实例、UiAbilityContext实例。其中NavPathStack实例、UiAbilityContext实例由宿主提供，scheme、routerParam由SDK回调函数提供。
示例如下：
```
onRouterToPage(scheme: string, routerParam: string,
    pushPathHandler?: (scheme: string, routerParams: string, pathStack?: NavPathStack,
      context?: common.UIAbilityContext) => boolean) {
    //获取宿主APP自己的pageStack
    const pathStack = Nav.getPathStack(); 
    //传pageStack和uiAbilityContext参数给handler
    if (pathStack && pushPathHandler?.(scheme, routerParam, pathStack, Nav.getUIContext())) {
      return;
    }
  }

onTerminateSdkPage(scheme: string, routerParam?: string,
    popPathHandler?: (pathStack?: NavPathStack, context?: common.UIAbilityContext) => boolean) {
    //获取宿主APP自己的pageStack  
    const pathStack = Nav.getPathStack();
    //传pageStack和uiAbilityContext参数给handler
    if (pathStack && popPathHandler?.(pathStack, Nav.getUIContext())) {
      return;
    }
}
```
---
#### 1.2.4.2 方案二（接入方自己处理SDK路由交互事件，接入场景复杂时使用）：

SDK的路由交互部分，由宿主自己在回调中完成交互。Sdk不做任何处理，仅回调路由参数。
示例如下：

```
onRouterToPage(scheme: string, routerParam: string,
    pushPathHandler?: (scheme: string, routerParams: string, pathStack?: NavPathStack,
      context?: common.UIAbilityContext) => boolean) {
    Nav.getPathStack().pushDestination({
      name: scheme,
      param: {
        param: routerParam
      } as ESObject
    })
  }

  onTerminateSdkPage(scheme: string, routerParam?: string,
    popPathHandler?: (pathStack?: NavPathStack, context?: common.UIAbilityContext) => boolean) {
    Nav.getPathStack().removeByName(scheme)
  }

```

#### 1.2.4.3 注意项
- **如果集成方使用了方案二，自己处理路由交互部分，需要集成方同时处理全屏状态变化和还原、屏幕旋转变化和还原等系统事件。**
- **集成方鸿蒙App中，需要使用鸿蒙官方推荐的Navigation和NavPathStack进行路由管理。同时路由中的页面顶层元素需要声明为NavDestination，否则可能无法路由到sdk页面。详细使用方式可参考SdkSample中的Index.ets和MeetingTab.ets实现**




# 2. FAQ
## 2.1 打包失败，提示targetAPIVersion diffent?
A: sdk的targetSdkVersion与宿主不一致导致，此时需要修改宿主的targetSdkVersion，与sdk保持一致。当前sdk版本（3.30），targetSdkVersion=13。

## 2.2 编译时遇到duplicate so问题?
A: 参考上文：[[so架构与so打包冲突解决]](#1.2.1.3-so架构与so打包冲突解决)

## 2.3 使用router路由集成TencentMeetingSDK后，无法正常拉起会议？
鸿蒙平台下，TencentMeetingSDK使用鸿蒙推荐的Navigation实现路由跳转。请升级到Navigation路由方式后尝试拉起会议。

同时，TencentMeetingSDK可使用兼容router方案进行临时接入（接入后需要尽快升级到Navigation路由方式确保用户体验），但需要集成方自己实现跳转SDK页面路由和退出SDK页面路由。兼容方案如下：
- 改造应用根页面，使用Navigation的路由方式，并初始化NavPathStack
- onRouterToPage()函数中，先router回到应用根页面，再执行pushPathHandler并传入相关参数，否则sdk页面会被其他page覆盖导致不可见。
