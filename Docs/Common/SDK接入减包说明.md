- [1. Android减包接入说明](#Android减包接入说明)
    * [1.1 接入指引](#接入指引)
    * [1.2 效果对比](#效果对比)
- [2. Windows减包接入说明](#Windows减包接入说明)
    * [2.1 接入指引](#接入指引-1)
    * [2.2 效果对比](#效果对比-1)
- [3. Mac减包接入说明](#Mac减包接入说明)
    * [3.1 接入指引](#接入指引-2)
    * [3.2 效果对比](#效果对比-2)

## Android减包接入说明
### 接入指引
Android TencentMeetingSDK默认包含armeabi-v7a和arm64-v8a这两种架构so，对于绝大多数android机型，现在已经支持运行64位应用， 因此我们可以根据自身情况，通过gradle脚本来配置构建出只包含64位架构so的apk来减小apk的体积，具体配置如下：
```
android {
    ...
    defaultConfig {
        ...
        ndk {
            //可以根据需求减少armeabi-v7a，只保留arm64-v8a，但是不能增加其他abi
            setAbiFilters(['arm64-v8a'])
        }
        ...
    }
    ...
}

```

### 效果对比
以TMSDK_Android_3.21.300.33版本为例，通过配置编译脚本使用arm64-v8a单架构集成比双架构包体积减少60.3M。
|打包架构|armeabi-v7a和arm64-v8a双架构|arm64-v8a|体积减少|
|--------------|--------|-----------------------|-------------------|
|demo apk大小|159.2MB|98.9MB|↓60.3MB|



## Windows减包接入说明
### 接入指引
tbs打包优化：打包可选择对Release\webview和Release\resources\webview目录删除，删除不影响接口调用，使用过程中会触发内置浏览器动态下载(首次初始化触发)。

### 效果对比
|打包| 有webview | 无webview | 减包大小 |
|--------------|----------|----------|------|
|exe大小| todo     | todo     | todo |



## Mac减包接入说明
### 接入指引
1. Mac TencentMeetingSDK是一个双架构的framework，默认包含x86和arm64两种架构，可以在x86和arm64下运行。客户也可以根据自身需求，选择对应x86或者arm64的单架构包
2. 双架构拆成单架构包操作，将SDK包里面的SDK目录下的TMSDK.framework和mac_build_framework放在同级目录，双击运行mac_build_framework，等待即可，无报错情况下会在当前目录下的Build/Products/Release/framework下生成x86和arm64两个平台的架构包

### 效果对比
以TMSDK_MacOS_3.21.300.30版本为例，按照上面的接入指引2中操作
|架构|包dmg大小|相对双架构包dmg减量 |
|---|---|---|
|x86 & arm64(双架构)|292.3MB|0MB|
|---|---|---|
|x86（单架构）|233.5MB|58.8MB|
|---|---|---|
|arm64（单架构）|227.8MB|64.5MB|

