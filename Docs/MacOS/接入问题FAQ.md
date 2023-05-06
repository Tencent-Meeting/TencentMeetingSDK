# FAQ

Q1.接入腾讯会议SDK的应用，导入TMSDK.framework到工程，运行时报错相关库找不到，比如Library not loaded: @rpath/tmsdk_wemeet_sdk.framework/Versions/A/tmsdk_wemeet_sdk

A：1、确认TMSDK.framework是否有问题，可以通过运行官方demo是否正常来判断。2、查看TMSDK.framework的库结构，建议拷贝TMSDK.framework库时使用cp -R 命令，确保库的拷贝操作正常并且保留原始目录的信息，下图中1是正确的库结构，图中2是错误的库结构。区别在于：如Headers在图中1是引用文件，在图中2是实体文件夹。

<img src="../Common/images/image_tree_tmsdk.png" alt="image_tree_tmsdk" style="zoom:80%;" />

