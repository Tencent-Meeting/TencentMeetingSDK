# FAQ

- 出现以下错误，请按照前面的工程配置，检查 SDK 头文件的目录是否正确添加：
> fatal error C1083: Cannot open include file: 'wemeet_sdk.h': No such file or directory

- 出现以下错误，请按照前面的工程配置，检查 SDK 库目录和库文件是否正确添加：
> LINK : fatal error LNK1104: 无法打开文件“wemeetsdk.lib”
> error LNK2019: 无法解析的外部符号 __imp__GetWemeetSDKInstance，该符号在函数 "protected: virtual int __thiscall CDemoDlg::OnInitDialog(void)" (?OnInitDialog@CDemoDlg@@MAEHXZ) 中被引用

- 出现以下错误，请按照前面的工程配置，检查 SDK 的 DLL 是否拷贝到执行目录：

    ![ 'image.png'](./res/4.png)

- 应用异常退出后，切换账号登录异常或者登录的账号信息错误
> 如果登录的账号发生切换，请主动调用登出接口以清空登录态，再重新尝试登录。
  
- 出现以下错误，请更改字符集为“使用多字节字符集”：
> C2664	“void IPreMeetingService::ShowMeetingDetailView(const char *,const char *)”: 无法将参数 1 从“wchar_t *”转换为“const char *”
