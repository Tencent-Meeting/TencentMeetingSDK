# Windows SDK提权服务接入指南

背景:
当存在需要动态安装扩展屏驱动或者虚拟声卡驱动等场景的时候无法进行提权操作，最终导致无法使
用一些特性功能影响用户体验。针对上述无法提权会议进程并安装虚拟驱动的场景，这里提供一种接入
提权服务集成到安装包里面的解决办法，避免安装虚拟驱动失败。

## 1. electron nsis接入提权服务(前提条件：安装程序为高权限)

### 1.1 版本环境提示

1. 本指南适用的 SDK 版本： v3.24.200及以上版本
2. 支持 win7 及其以上的系统

### 1.2 electron-builder 集成nsis提权服务的方式

压缩包的目录结构
| 目录名     | 说明                         |
| ---------- | ---------------------------- |
| Demo      |  MFC demo(新版本切换至Qt Demo)           |
| Electron_Demo    | (electron接入C++ node插件demo)     |
| QtDemo     |  新版本qt demo   |
| SDK | 包含接入需要的所有依赖库目录 |

如下重点描述如何接入nsis脚本（Electron_Demo的目录结构）：

| 目录名     | 说明                         |
| ---------- | ---------------------------- |
| build      | 包含接入nsis的脚本           |
| include    | 生成node C++插件的头文件     |
| output     | 包含32/64位 node生成的插件   |
| wemeet_sdk | 生成node C++插件使用的源文件 |

#### 1.2.1 electron-builder集成nsis的脚本

![1.png](res/1.2.png)
集成脚本需要再package.json中指定需要引入的文件
![1.png](res/1.3.png)

#### 1.2.2 service_setup.nsh说明

```javascript
!macro customInstall
    WeMeetHelper::LogInit
    WeMeetHelper::LogInfo "InstallService: ${SERVICE_PRODUCT_EXE_NAME}."
    !insertmacro UAC_IsAdmin
    StrCpy $7 $0
    ${If} $7 == "1"
      !insertmacro CheckInstalledService $R3 
      ${If} $R3 == "1"
        !insertmacro StopService
        WeMeetHelper::KillProcessByName "${SERVICE_PRODUCT_EXE_NAME}" 1
        ${If} ${FileExists} "${SERVICE_DEFAULT_INSTALL_DIR}\${SERVICE_PRODUCT_EXE_NAME}"
          !insertmacro WaiteFileWriteable "${SERVICE_DEFAULT_INSTALL_DIR}\${SERVICE_PRODUCT_EXE_NAME}" 3 $1
          WeMeetHelper::LogInfo "service file exist, wait writeable ret:$1."
          ${If} $1 == ${ERROR_FILE_CHECK_TIMEOUT}
            WeMeetHelper::LogInfo "wait service file timeout, just extract to temp."
            !insertmacro ExtractServiceToPath ${SERVICE_DEFAULT_INSTALL_DIR} ${SERVICE_PRODUCT_EXE_NAME_TEMP}
            System::Call 'KERNEL32::MoveFileEx(t "${SERVICE_DEFAULT_INSTALL_DIR}\${SERVICE_PRODUCT_EXE_NAME}", i 0, i 4)'
            System::Call 'KERNEL32::MoveFileEx(t "${SERVICE_DEFAULT_INSTALL_DIR}\${SERVICE_PRODUCT_EXE_NAME_TEMP}", t "${SERVICE_DEFAULT_INSTALL_DIR}\${SERVICE_PRODUCT_EXE_NAME}", i 4)'
          ${Else}
            WeMeetHelper::LogInfo "service file is writeable, just extract."
            !insertmacro ExtractServiceToPath ${SERVICE_DEFAULT_INSTALL_DIR} ${SERVICE_PRODUCT_EXE_NAME}
          ${EndIf}
        ${Else}
          WeMeetHelper::LogInfo "service file not exist, just extract."
          !insertmacro ExtractServiceToPath ${SERVICE_DEFAULT_INSTALL_DIR} ${SERVICE_PRODUCT_EXE_NAME}
          !insertmacro RegeditService
        ${EndIf}
      ${Else}
        WeMeetHelper::LogInfo "service not installed, just write."
        !insertmacro ExtractServiceToPath ${SERVICE_DEFAULT_INSTALL_DIR} ${SERVICE_PRODUCT_EXE_NAME}
        !insertmacro RegeditService
      ${EndIf}
      !insertmacro SetRXRights "${SERVICE_TEMP_DIR}\${SERVICE_PRODUCT_EXE_NAME}"
      !insertmacro SetRXRights "${SERVICE_DEFAULT_INSTALL_DIR}\${SERVICE_PRODUCT_EXE_NAME}"
       ClearErrors
    ${Else}
      WeMeetHelper::LogInfo "current process need evalute"
    ${EndIf}
  !macroend
```

主要流程逻辑:
1.检测本安装程序是否为高权限，如果是高权限走覆盖安装提权服务TMSDKUpdateService.exe的流程
2.不是高权限，默认不安装提权服务。

集成方需要保证customInstall执行上述处理,
  1.保证安装过程日志输出，便于排查安装中的问题

```javascript
   WeMeetHelper::LogInit  
```

  2.保证将TMSDKUpdateService.exe输出到指定目录

```javascript
   !insertmacro ExtractServiceToPath ${SERVICE_DEFAULT_INSTALL_DIR} ${SERVICE_PRODUCT_EXE_NAME} 
```

  3.保证将执行TMSDKUpdateService.exe /service true 指令，用来注册提权服务

```javascript
    !insertmacro RegeditService
```

#### 1.2.3 集成后的安装目录结构

执行customeinstall后提权服务TMSDKUpdateService.exe一般存放在:

```javascript
 !define SERVICE_DEFAULT_INSTALL_DIR   "$PROGRAMFILES\${COMPANY_NAME}\UpdateSvr"  
```

注意:
SERVICE_DEFAULT_INSTALL_DIR 在define_service.nsh中指定，集成方可以指定和修改对应的目录，其中COMPANY_NAME可以在package.json中指定。

![10.png](res/1.4.png)

## 2. 集成提权服务验证

通过上面的接入指南接入TMSDKUpdateService.exe, 执行安装包, 安装到SERVICE_DEFAULT_INSTALL_DIR目录之后，可通过启动会议sdk进行验证;
1.检验扩展屏驱动是否能正常安装:(未装扩展屏驱动截图)
   ![10.png](res/1.5.png)
2.启动会议sdk初始化登录之后驱动安装成功，并显示扩展屏投屏入
   ![10.png](res/1.6.png)
   ![10.png](res/1.7.png)
3.任务管理器服务运行
   ![10.png](res/1.8.png)

## 3. 原生接入

原生接入使用nsis脚本同理，需要将service_setup.nsh引入进去，并且将custominstall部分的逻辑放置在安装过程中执行流程中即可
