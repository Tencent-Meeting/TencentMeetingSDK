# Electron 接入手册 - Linux

## 1. demo环境配置说明
### 1.1 环境要求
1. 操作系统：与SaaS SDK支持类型和CPU架构一致，可参考[Linux接入手册](../Linux/Linux接入手册.md)。
2. NodeJS：推荐使用最新的LTS版本，在旧版本上可能会出现编译的native代码与Electron ABI不兼容问题。

### 1.2 文件说明
为了简化 electron 的接入，我们封装了一个 node.js 的 addon，可以在 electron 中直接导入这个addon，使用里面封装的接口即可。
这个 nodejs 的 addon 的名字是 wemeet_electron_sdk.node, Windows，macOS 和 Linux 都是这个名字。

> **说明：在Windows，macOS和Linux上wemeet_electron_sdk.node的依赖文件是不一样的，但是我们提供的 .node 文件导出的接口是一致的，所以编码接入的时候无需平台的差异性，打包的时候将对应平台的依赖文件对应目录即可。**

### 1.3 运行demo

以下是通用的初始化和构建运行流程。**对于LoongArch64架构的机器，要在本地构建运行，请参考下一节内容说明**。

``` shell
# 1. 拷贝node依赖的SDK文件（如果output/linux/目录下没有相关文件），文件结构参考下文接入配置说明。
# 1.1 在demo目录下提供了拷贝SDK文件的脚本，可查看其中内容了解拷贝的文件以及结构。
./copy_sdk_build_linux.sh

# 2. 运行构建脚本，脚本会自动拷贝 .node 文件到 output/linux/ 目录下
./configure.sh --build
# 2.1 再次构建时可跳过npm install过程，添加--skip-install参数即可
./configure.sh --build --skip-install

# 3. 启动demo
npm run start
```

其中拷贝SDK依赖文件的操作正常情况下只需要执行一次初始化即可；如果没有native代码和npm依赖等变更，也无须重新编译构建。

有关具体的构建步骤，可参考`configure.sh`文件。

#### 1.3.1 LoongArch64本地构建

LoongArch64架构由于没有Electron官方仓库的原生支持，因此在编译时需要单独执行一些设置。对于demo，我们已经将相关设置和命令封装到了`npm_install_loognarch64.sh`脚本之中，可直接运行配置LoongArch64环境。

``` shell
# 1. 拷贝node依赖的SDK文件
./copy_sdk_build_linux.sh

# 2. 执行npm install操作，运行构建脚本，拷贝 .node 文件
./npm_install_loognarch64.sh

# 3. 启动demo
npm run start
```

有关LoongArch64的构建操作，可自行参考上面的脚本文件内容。

关于LoongArch64架构下Electron使用文档，可参考[龙芯官网资料](https://docs.loongnix.cn/electron/electron.html)。
包含Electron以及Electron Builder的使用方法。


## 2. SDK 接入说明
### 2.1 申请 SDK Id & SDK Secret

为了让SDK正常使用，需要为SDK配置独有的安全凭证，安全凭证包括SDK Id和SDK Secret，对每一次请求进行验证。联系腾讯会议商务对接人进行信息登记。

### 2.2 SDK 接入配置

1. 安装NodeJS，建议使用最新的LTS版本，可在Node官网下载。
2. 新建Electron工程。
3. 在package.json增加Electron等依赖，可参考上面的demo工程，对于LoongArch64架构需要注意版本号。
4. 拷贝SDK依赖。对于Linux，需要将`libwemeetsdk.so`,`libwemeet_base.so`以及`Release`目录从SDK中拷贝到工程的`.node`文件同级目录下。可参考demo中`configure.sh`文件，生成的node文件被拷贝到`output/linux`下，SDK依赖也放置在该目录。
5. 拷贝SDK头文件到当前目录下，以方便开发。打包时候无需携带头文件。
6. 在package.json加配置
``` javascript
"scripts": {
    "start": "node start.js && electron ."
},
```
7. 修改node-gyp编译配置，可参考demo binding.gyp文件，其中配置了native代码编译时候的头文件和Library搜索路径。
6. 在js中导入 wemeet_electron_sdk.node 文件
``` javascript
   // path_to_your_wemeet_electron_sdk.node 表示 wemeet_electron_sdk.node的路径
   const wemeet_sdk = require('path_to_your_wemeet_electron_sdk.node')
   // 这里导入的 wemeet_sdk 会在接下来的接口说明中使用
```


## 3. 接口说明

Linux下的Electron接口与其他平台一致，可参考[Electron接入手册](./Electron接入手册.md#3-接口说明)。
