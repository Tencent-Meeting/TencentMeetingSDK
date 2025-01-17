![image](https://github.com/user-attachments/assets/efbe30e9-1c1e-49a8-baa2-7aecc67c7051)# Linux接入问题 / FAQ

**在遇到相关问题之前，可以使用demo在相同环境下运行对比一下表现。**

---

* 调用初始化接口回调失败，msg：`InitializeStateIng ipc connect failed`。

该问题通常是由于会议子进程启动失败导致，可以在终端使用`ps -ef | grep wemeetapp`等命令检查是否存在会议子进程，必要时候可以关注父进程PID等信息以进行确认。

如果子进程未启动，而demo程序可正常运行的话，通常原因是会议进程入口文件（位于Release目录）丢失了可执行权限导致，一般是由于拷贝/在图形化桌面的文件管理器中拖动目录等操作导致。可在终端打开会议Release目录，手动设置`x`权限：`chmod ug+x wemeetapp`。

如果确认为丢失可执行权限导致，说明会议资源目录（Release目录）在放置到工程目录和最终打包时操作有问题，建议重新设置。简单来说，删除之前拷贝进来的资源目录，重新执行`cp`命令拷贝，需要携带`-p`参数，**以保留所有文件属性**，具体有关`cp`命令操作，可以运行`man cp`获取系统自带帮助文档。或者在使用`tar`解压SDK压缩文件之后，使用`mv`命令也会保留所有文件属性。

有关打包更多操作和要求，可以参考[Linux打包](./Linux接入手册.md#44-打包)。

* Linux SDK在wayland下初始化提示 'wayland display is not support'。

Linux SDK目前不支持原生wayland，这里uos和kylin os操作系统厂商对xwayland进行了改造，完成了/opt/x11-wayland的补丁，使得Linux SDK在uos和kylinOS 的wayland下可以正常运行。在没有改造的发行版上，会议在wayland下是不支持的。

可以通过如下方式解决：
1.引导用户切换至x11下使用Linux SDK
2.若用户有wayland强诉求，确认用户是否为uos和kylin os操作系统，其他系统不支持
3.确认/opt/x11-wayland文件夹是否存在，缺少补丁联系对应系统操作系统厂商提供

* Linux SDK发生闪退/崩溃

排查建议：
1.让用户在终端输入coredumpctl list wemeetapp，查看是否有会议进程崩溃记录
2.终端输入coredumpctl dump -o ~/Desktop/wemeetapp.coredump SDK安装目录/Release/tmsdkapp 提取dump文件
3.让客户提供桌面的wemeetapp.coredump文件给研发侧分析堆栈

补充场景：
1.文件wemeetapp.coredump 大小为 0kb
这是由于系统限制了崩溃时core文件的大小限制，在终端中ulimit -c unlimited，设置不限制后，复现崩溃场景后再重新提取dump

2.终端输入coredumpctl dump -o ~/Desktop/wemeetapp.coredump SDK安装目录/Release/tmsdkapp 提取dump文件提示文件夹不存在
这是因为有的系统的桌面路径不是“Desktop”，而是中文的“桌面"，对应替换即可，coredumpctl dump -o ~/桌面/wemeetapp.coredump SDK安装目录/Release/tmsdkapp
