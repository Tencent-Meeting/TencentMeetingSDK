 # Windows 64位SDK接入手册
  
  ## 1. 集成接入指南
  ### 1.1 版本环境提示
  - 本指南适用的 Windows 64位SDK 版本： v3.30.300及以上版本
  - 支持 win7 及其以上的系统

  ### 1.2 运行前拷贝依赖
  **1、宿主如果是32位，接32位的sdk，可以直接使用x86的zip包中的SDK**
  
  **2、宿主如果是64位，接64位的sdk，可以直接使用x64的zip包中的SDK**
  
  **3、宿主如果是32位，接64位的sdk，需要拷贝x86的zip中SDK目录下的系统库，wemeetsdk_x86.dll，wemeet_base.dll文件到会议目录；拷贝x64的zip中SDK的Release目录到会议目录**
  
  **4、宿主如果是64位，接32位的sdk，需要拷贝x64的zip中SDK目录下的系统库，wemeetsdk_x64.dll，wemeet_base.dll文件到会议目录；拷贝x86的zip下SDK的Release目录到会议目录**

  
  ### 1.3 拷贝node(electron接入)
  **参考 [Electron接入手册](./Docs/Linux/Linux接入手册.md) 1.3章节中生成和拷贝node的方法**
