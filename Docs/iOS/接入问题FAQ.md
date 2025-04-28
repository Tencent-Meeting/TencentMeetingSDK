# FAQ

Q1.接入腾讯会议SDK的应用，Archive后的产物，点击Distribute APP，使用AppStore Connect导出的启动时会崩溃。但是用Adhoc打包ipa安装又是正常的。

A：根本原因是打包过程中，修改了SDK内部的framework的版本号，导致了相对应的部分模块没有加载而crash。打包时请注意下面的选项：Manage Version and Build Number。

<img src="./images/Xnip2021-12-07_19-12-16.png" alt="Xnip2021-12-06_10-27-10" style="zoom:30%;" />

Q2.初始化和登录都有收到成功回调，调用入会接口没看弹框也没收到回调

A: 未初始化SDK前，先调用了accountService的isLogin函数，导致accountService里面的监听在第一次初始化的时候未生效，而accountService是一个单例，监听的方法写在了后续SDK init时也不会调用。请检查是否在TMSDK init方法前调用AccountService的方法，如isLogin方法，所有的SDK方法需要在TMSDK初始化之后才能使用。

Q3.开启悬浮窗后，退出会中页面回到App内，横屏下悬浮窗不显示或显示位置不对

A: 工程未设置mulWindow和SceneDelegate，旋转后frame的中心参照点有问题，不是固定的设备左上角，导致悬浮窗未能更新到正确的位置。请检查工程是否已经支持mulWindow及SceneDelegate，如下图所示：

<img src="./images/project_mut_win.png" alt="1" style="zoom:67%;" />
注意：不要勾选上面的full screen，否则在iOS13手机上依然会有问题

<img src="./images/project_info_plist.png" alt="1" style="zoom:67%;" />

注意：如果你的应用以前不支持Scene delegate，那么在你进行改造支持后，需要注意AppDelegate相关方法到SceneDelegate的迁移

Q4.接入SDK 后，会中横竖屏问题。

A: 横竖屏设置的优先级顺序是：Appdelegate/Info.plist=>TabBarController=>NavigationController=>ViewController。目前SDK在NavigationController=>ViewController这个已经设置支持会中页面MeetingViewController转屏，但由于横竖屏的优先级问题，仍需您在自己的App里设置会议相关VC支持横竖屏。如您的App层级为Tabber->Nav，则需要在Tabbar和Nav的基类里都支持相关VC横竖屏，下面是在Tabbar里配置相关VC横竖屏的代码，iOS横竖屏具体知识可参照这篇文章[iOS横竖屏适配](https://www.jianshu.com/p/a2201f39b6a7)
```

1、在你们的自定义的UITabBarController，添加以下方法
// 支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.selectedViewController;
    NSMutableArray<NSString *> *classList = [NSMutableArray new];
    [classList addObject:@"MeetingViewController"];
    [classList addObject:@"UserInfoViewController"];
    [classList addObject:@"HandsupViewController"];
    [classList addObject:@"MeetingSettingViewController"];
    [classList addObject:@"WMFaceBeautySettingViewController"];
    [classList addObject:@"RedPacketSendViewController"];
    [classList addObject:@"RedPacketDetailViewController"];
    [classList addObject:@"WMWatchLiveViewController"];
    BOOL needLandscape = NO;
    for (NSString *item in classList) {
        if ([topVC isKindOfClass:NSClassFromString(item)]) {
            needLandscape = YES;
            break;
        }
    }
    if (needLandscape) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
2、在你们的自定义的UITabBarController，添加以下方法
- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.selectedViewController;
    NSMutableArray<NSString *> *classList = [NSMutableArray new];
   	[classList addObject:@"MeetingViewController"];
    [classList addObject:@"UserInfoViewController"];
    [classList addObject:@"HandsupViewController"];
    [classList addObject:@"MeetingSettingViewController"];
    [classList addObject:@"WMFaceBeautySettingViewController"];
    [classList addObject:@"RedPacketSendViewController"];
    [classList addObject:@"RedPacketDetailViewController"];
    [classList addObject:@"WMWatchLiveViewController"];
    BOOL needLandscape = NO;
    for (NSString *item in classList) {
        if ([topVC isKindOfClass:NSClassFromString(item)]) {
            needLandscape = YES;
            break;
        }
    }
    return needLandscape;
}
3. 以下window需要支持全方向：
    WMWebEmbededFullScreenWindow
```



Q5.预定会议后的邮件UI异常问题。

<img src="./images/Xnip2021-12-07_19-11-31.png" alt="1" style="zoom:67%;" />

A:检查下主APP 中是否含有**FDFullscreenPopGesture** 这个库

Q6.共享屏幕没反应，倒计时3秒  然后没有录屏效果。

A：请检查extension。建议用WemeetExtension，原来的扩展名(BroadcastUploadExtension)太通用，有可能会重名。需要后缀改成WemeetExtension，扩展的后缀要是主app的bundle id + .WemeetExtension

Q7.masonry 导致的crash问题。

A: 使用这个版本，  pod 'Masonry', :git => 'https://github.com/SnapKit/Masonry.git', :commit => '8bd77ea' # fixbug use this commit

Q8.crash 日志：`Terminating app due to uncaught exception 'UIViewControllerHierarchyInconsistency', reason: 'child view controller:<UserInfoPopoverViewController: 0x10c01e460> should have parent view controller:(null) but actual parent is:<UIViewController: 0x10850dca0>'terminating with uncaught exception of type`

A: SDK 内部已做兼容处理。

Q9.从会中页面进入美颜等二级页面，控制器UI层级异常。

A: 请检查是否含有 **FDFullscreenPopGesture**这个第三方库。

Q10.接入会议和其他三方视频会议SDK，会议中有时无法正常屏幕共享的问题。

A: 确保您的App应该共用一个**Apple Broadcast UploadExtension**（沿用APP之前Extension的bundleId，不需要改名）
<img src="./images/tencent_meeting_broadcast_image_A.png" alt="1" style="zoom:67%;" />

B: TencentMeetingSDK初始化时，设置初始化参数TMInitParam的extensionBundleId为APP已存在的拓展的Bundle Id
<img src="./images/extension_bundle_id.jpg" alt="1" style="zoom:67%;" />

C:开始进入腾讯视频会议时：
<img src="./images/tencent_meeting_broadcast_image_B.png" alt="1" style="zoom:67%;" />

开始进入三方视频会议时：
<img src="./images/tencent_meeting_broadcast_image_B1.png" alt="1" style="zoom:67%;" />

D:在 **Broadcast UploadExtension** 中**SampleHandler.m**中：
<img src="./images/tencent_meeting_broadcast_image_C.png" alt="1" style="zoom:67%;" />
