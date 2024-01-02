# Linux SDK接入手册

本文档适用于Linux SaaS SDK v3.19.1及以上版本。

## 1. 环境需求
Linux SaaS SDK支持以下CPU架构和Linux发行版：

1. CPU架构
  * X86/X64
  * ARM64
  * Loongarch

2. Linux发行版
  * 统信V20
  * Deepin V20
  * 麒麟V10
  * Ubuntu 18.04及以上

其它发行版与CPU架构未经测试，暂时无法确认兼容性。

## 2. SDK包组成

```
SDK/
 ├-- include/
 ├-- Release/
 ├-- res/
 ├-- wemeetsdk_qt_demo
 ├-- wemeetsdk_qt_demo.sh
 ├-- libwemeet_base.so
 ├-- libwemeetsdk.so
 └-- lib{xxx}.so
```

* `include`: Linux SDK头文件目录。
* `Release`: Linux SDK依赖的资源等内容目录。
* `libwemeet_base.so` & `libwemeetsdk.so`: Linux SDK动态库。

其它文件和目录为demo依赖以及帮助支持文件。

## 3. 运行demo

打开一个终端页面，导航到SDK根目录下，运行`wemeet_qt_demo.sh`脚本即可。

``` shell
$ /path/to/sdk > ./wemmet_qt_demo.sh
```

> 如果因为一些问题导致`wemeet_qt_demo.sh`文件没有了可执行权限，可使用`chmod`命令手动修复。如`chmod ug+x wemeet_qt_demo.sh`。

**注意**：使用`wemeet_qt_demo.sh`运行demo程序，而不要直接执行`wemeet_qt_demo`文件，因为`wemeet_qt_demo`程序依赖的动态库文件都在SDK目录下，需要导出`LD_LIBRARY_PATH`以及`PATH`等环境变量才能启动运行。具体实现可以查看`wemeet_qt_demo.sh`文件内容。

## 4. 集成SDK

要将SDK添加到你的应用工程中，需要在编译构建和打包两个步骤做相应集成。

> 以下使用`app`指代工程跟路径。

### 4.1 编译依赖

Linux SDK提供的动态库文件依赖`libc.so.6`/`libstdc++.so.6`标准库文件，因此在你的构建机器上应当有对应的兼容性环境。通常情况下使用上述列出的Linux发行版本都已经有相关依赖环境。

对于编译器，推荐使用支持`C++11`/`C++14`等现代C++标准的编译器。

其它工具如`CMake`等取决于你的项目管理配置。

### 4.2 构建编译

首先将SDK相关文件拷贝到项目工程下，例如`WemeetSDK`目录中。（path: `/app/WemeetSDK/`）

> SDK相关文件有：
> * `include/` 头文件目录
> * `Release/` 资源内容依赖目录
> * `libwemeet_base.so` SDK动态库文件
> * `libwemeetsdk.so` SDK动态库文件

拷贝完成之后的工程目录树类似于：

```
app/
 ├-- WemeetSDK/
   ├-- include/
   ├-- Release/
   ├-- libwemeet_base.so
   └-- libwemeetsdk.so
 └-- YourOtherFiles
```

下面以CMake配置为例，将SDK相关文件添加到构建依赖中。**假设你的`CMakeLists.txt`文件与`WemeetSDK`目录同级，如果相对位置有差异，请适配修改以下配置中的相对路径。**

1. 添加头文件依赖路径

``` cmake
target_include_directories(${YOUR_TARGET} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/WemeetSDK/include)
```

2. 添加链接路径

``` cmake
target_link_directories(${YOUR_TARGET} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/WemeetSDK)
```

3. 链接SDK动态库

``` cmake
target_link_libraries(${YOUR_TARGET} PRIVATE wemeetsdk wemeet_base)
```

使用其它构建工具的可以参考上述配置内容进行配置。本质上就是告诉编译器在编译和链接时候在何处搜索头文件以及动态库。

### 4.3 打包

无论是在调试阶段还是最后发布正式包，在最终运行程序的文件夹布局中，都需要满足一个约束：`Release/`目录和`libwemeet_base.so`/`libwemeetsdk.so`文件**必须**位于同一个目录层级下。

因此，如果你的工程在调试阶段有自定义output路径，那么当在调试构建拷贝动态库文件结束后，需要确保`Release/`目录也被拷贝到相同路径下了。

而对于最终打包发布，需要确保解压后或者通过安装程序安装之后，`Release/`目录位于`libwemeetsdk.so`同级路径下。

### 4.4 运行

因为SDK运行需要的资源都位于`Release`目录下，包括依赖的动态库文件，因此在运行你的app进程时，需要导出一些环境变量设置，以确保SDK子进程可以正确加载动态库和运行。

具体配置可以参考demo启动脚本文件`wemeet_qt_demo.sh`。

## 5. 快速使用

此处简述SDK常用使用方式，更多具体接口和描述，参考[《TencentMeetingSDK（TMSDK）接口参考文档》](../Common/TencentMeetingSDK（TMSDK）接口参考文档.md)。

有关鉴权与登录相关内容，参考[《SDK鉴权与登录说明》](../Common/SDK鉴权与登录说明.md)。

### 5.1 引入SDK头文件

``` c++
#include <wemeet_sdk.h>
```

### 5.2 初始化

**注意**：因为Linux图形程序没有标准的接口操作类似UI线程这样的概念，因此Linux SDK本身是运行在一个独立线程中，包括所有的回调函数在默认情况下也是运行在该线程中。所以如果你使用了图形框架，而且希望在UI线程中处理SDK回调，那么你需要在初始化之前首先调用`IWemeetSDK::SetThreadDispatcher`函数设置线程调度同步。具体操作参考[《Linux线程同步》](./Linux线程同步.md)

> SDK目录下`res`文件夹中提供了线程设置参考文件和文档。

``` c++
// 设置SDK线程与UI线程同步
GetWemeetSDKInstance()->SetThreadDispatcher(&this->dispatcher_obj_);

InitParams params;
params.sdk_id = "sdk_id";
params.sdk_token = "sdk_token";
params.data_path = sdk_path.c_str(); // 【必填】日志和配置保存目录，需要utf-8编码
params.app_name = ""; //品牌名称
params.app_icon = ""; //工具栏图标路径，需要utf-8编码
// 其它参数设置...
GetWemeetSDKInstance()->Initialize(params, this)
```

### 5.3 设置回调

部分接口调用结果，包括一些UI操作的事件，都是通过SDK回调返回的。要处理相关任务，需要先设置回调接口。

``` c++
GetWemeetSDKInstance()->GetAccountService()->SetCallback(this);
GetWemeetSDKInstance()->GetPreMeetingService()->SetCallback(this);
GetWemeetSDKInstance()->GetInMeetingService()->SetCallback(this);
```

### 5.4 登录/登出

调用登录接口，`sso_url`字符串需要自行获取拼接。

``` c++
auto id_token = GetIdToken();
auto url_prefix = GetUrlPrefix();
auto sso_url /* : std::string */ = url_prefix + id_token;
GetWemeetSDKInstance()->GetAccountService()->Login(sso_url.c_str());
```

退出登录：

``` c++
GetWemeetSDKInstance()->GetAccountService()->Logout();
```

### 5.5 入会/退会

入会相关参数需要外部准备。

``` c++
JoinMeetingParams params;
params.meeting_code = ""; //【必填】会议号
params.user_display_name = ""; //入会昵称，如果空则使用登录账号的昵称
params.password = ""; //入会密码
params.invite_url = ""; //如果为空显示腾讯会议的邀请链接
params.face_beauty_on = true; //是否入会开启美颜
params.mic_on = true; //是否入会开启麦克风
params.camera_on = false; //是否入会开启摄像头
// 其它入会参数设置...
GetWemeetSDKInstance()->GetPreMeetingService()->JoinMeeting(param);
```

退出会议：

``` c++
bool end_meeting = ShouldCloseMeeting();
GetWemeetSDKInstance()->GetPreMeetingService()->LeaveMeeting(end_meeting);
```

### 5.6 反初始化

当退出app进程时，可以主动反初始化SDK。注意反初始化操作是异步的，当调用返回时，不代表已经反初始化结束。只有反初始化操作回调执行时，才表示其操作完成。

``` c++
// 结束正在进行的会议
std::string params = R"({"force": true})";
GetWemeetSDKInstance()->Uninitialize(params.c_str());
```
