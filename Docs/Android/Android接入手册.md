
## 1. Android SDK 集成接入指南

### 1.1 版本环境提示
- 您可以按照下面的方式在会议SDK集成环境中应用SDK接入问题检查插件，该插件将生成名为check${BuildVariantName}IntegrationIssue的task（其中${BuildVariantName}替换为构建变体的名字），在根项目目录中执行gradlew check${BuildVariantName}IntegrationIssue或在Android Studio的Gradle窗口找到该task并运行，task输的日志中将包含插件检查出的一些可能出现的SDK接入问题以及修改建议
```
// root project build.gradle
buildscript {
    dependencies {
        classpath 'com.tencent.wemeet.sdk:issue-checker:0.0.1'
    }
}

// app module build.gradle
plugins {
    id 'com.tencent.wemeet.sdk.plugin.checker'
}

```
- 支持 minsdkVersion 21
- Glide 4.12.0及以上
- 使用Android Studio作为IDE
- 如果您还在使用android.support.*，建议您迁移到AndroidX，建议迁移前满足以下条件
	1. Android Studio 3.2及以上
	1. AGP版本4.2.0及以上
	1. KGP版本1.4.0及以上
	1. Gradle版本6.7.1及以上
	1. 项目编译版本31及以上
	1. NDK版本21及以上
	1. JDK版本11及以上
- 迁移到Android X步骤
	1. 在Android studio中点击`Refactor > Migrate to AndroidX`，依照提示进行迁移即可。(迁移过程遇到问题可以参考官方文档)
	1. 通过反射取support包内class的代码，可以全局搜索android.support找到对应的位置手动名进行替换
	1. 如果项目中有对support库进行混淆配置，需要针对对应的AndroidX加上相应的混淆配置
- 如果您的应用的targetSdkVersion >= 31，请在AndroidManifest.xml中添加以下标签，如果没有添加，当您的应用运行在Android 12及以上版本系统时美颜功能可能无法正常工作
```
<uses-native-library
    android:name="libOpenCL.so"
    android:required="false"/>
<uses-native-library
    android:name="libGLES_mali.so"
    android:required="false"/>
<uses-native-library
    android:name="libPVROCL.so"
    android:required="false"/>
<uses-native-library
    android:name="libllvm-a3xx.so"
    android:required="false"/>
```
- 如果需要混淆代码，为了保证sdk的正常使用，需要在proguard配置文件中加上：

```
# 保留Annotation不混淆
-keepattributes *Annotation*,InnerClasses

# 避免混淆泛型
-keepattributes Signature

# 抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable

-keep class android.support.** {*;}
-keep public class * extends android.support.v4.**
-keep public class * extends android.support.v7.**
-keep public class * extends android.support.annotation.**

-keep class **.R$* {*;}

-dontwarn com.tencent.wemeet.sdk.beauty.**
-keep public class com.tencent.wemeet.sdk.beauty.BeautyBridge { *;}

-dontwarn com.tencent.youtu.YTUploader.**
-keep public class com.tencent.youtu.YTUploader.YTCLGLUploader { *;}

-dontwarn com.tencent.ttpic.facedetect.**
-keep class com.tencent.ttpic.facedetect.** { *;}

# 保留本地native方法不被混淆
-keepclasseswithmembernames class * {
    native <methods>;
}

-keep class kotlin.** {*;}
-keep class kotlinx.** {*;}
-dontwarn kotlinx.coroutines.**

-dontwarn com.tencent.mid.**
-keep class com.tencent.mid.** { *;}

-dontwarn com.tencent.itlogin.**
-keep class com.tencent.itlogin.** { *;}

-dontwarn com.tencent.wework.api.**
-keep class com.tencent.wework.api.** { *;}
-keep class com.tencent.wework.api.**{*;}

-dontwarn com.tencent.mm.**
-keep class com.tencent.mm.** { *;}

-dontwarn com.jg.**
-keep class com.jg.** { *;}
-dontwarn javax.lang.**
-keep class javax.lang.** { *;}
-keep class java.lang.** {*;}

#xcast
-keep class xcast.** {*;}
-keep class com.tencent.av.** {*;}
-keep class com.tencent.avlab.** {*;}
-keep class com.tencent.kapalaiadapter.** {*;}
-keep class com.tencent.sharp.** {*;}
-keep class com.tencent.xcast.** {*;}

#im sdk
-keep class com.tencent.imsdk.** {*;}

#EventBus
-keepattributes *Annotation*
-keepclassmembers class * {
    @org.greenrobot.eventbus.Subscribe <methods>;
}
-keep enum org.greenrobot.eventbus.ThreadMode { *; }
-keepclassmembers class * extends org.greenrobot.eventbus.util.ThrowableFailureEvent {
    <init>(java.lang.Throwable);
}

-keep class android.support.v7.widget.RecyclerView {
    int[] mScrollOffset;
}

-keep class com.tencent.wemeet.sdk.appcommon.** {*;}

#route相关
-keep class * implements com.tencent.wemeet.sdk.router.facade.template.IProvider{*;}
-keep class * implements com.tencent.wemeet.sdk.router.facade.template.IInterceptor{*;}
-keep public class com.tencent.wemeet.router.routes.**{*;}
-keep class * implements com.tencent.wemeet.sdk.router.facade.template.ISyringe{*;}
-keep interface * implements com.tencent.wemeet.sdk.router.facade.template.IProvider

# VMProperty
-keepclassmembers class * {
    @com.tencent.wemeet.sdk.appcommon.mvvm.annotation.VMProperty <methods>;
    @com.tencent.wemeet.sdk.appcommon.mvvm.annotation.VMCall <methods>;
}

-keepclassmembers class * extends android.view.View {
    *** get*();
    void set*(***);
}

-dontwarn com.tencent.wemeet.sdk.meeting.inmeeting.**
-dontwarn com.tencent.wemeet.sdk.meeting.premeeting.**
-keep class com.tencent.wemeet.sdk.base.widget.dialog.CustomDialog{*;}

-keep class com.tencent.wemeet.sdk.base.widget.dialog.WmNativeDialog{*;}
-keep class com.google.devtools.build.android.desugar.runtime.ThrowableExtension{*;}

-keepclassmembers class * extends android.webkit.WebChromeClient{
    public void openFileChooser(...);
}

# tbs 混淆
-dontwarn dalvik.**
-dontwarn com.tencent.smtt.**

-keep class com.tencent.smtt.** {
    *;
}

-keep class com.tencent.tbs.** {
    *;
}

-keepclassmembers class com.tencent.tmboard.sdk.view.WhiteBoardView{
    public void onConfigChangeUpdate(...);
}

-keepclasseswithmembers class * {
    native <methods>;
}

# ModuleRuntime
-keep class * extends com.tencent.wemeet.sdk.appcommon.modularization.ModuleRuntime {
    *;
}
-keep class com.tencent.wemeet.module.loader.ModuleLoadApi { *; }
-keep class com.tencent.wemeet.module.install.ModuleInstallApi { *; }

#qapm
-keep class com.tencent.qapmsdk.**{*;}
-keep public class com.tencent.wemeet.app.qapm.QAPMHelper { *;}
-keep public class com.tencent.wemeet.app.qapm.QAPMHelper$ThreadTrace { *;}


-keep class androidx.lifecycle.ReportFragment
-keep class android.app.ResourcesManager { *; }
-keep class android.content.res.ResourcesKey { *; }
-keep class com.tencent.wemeet.**{*;}

```
- 如果项目开启了资源混淆，例如AndResGuard，需在资源混淆白名单中加上：
```
[
    // your icon
    "R.mipmap.ic_logo",
    "R.mipmap.ic_logo_round",
    // for fabric
    "R.string.com.crashlytics.*",
    // for google-services.json
    "R.string.google_app_id",
    "R.string.gcm_defaultSenderId",
    "R.string.default_web_client_id",
    "R.string.ga_trackingId",
    "R.string.firebase_database_url",
    "R.string.google_api_key",
    "R.string.google_crash_reporting_api_key",
    "R.id.rpItemCover",
    "R.id.rpItemDetail",
    "R.raw.ring",
    "R.layout.home_menu_bar_debug_state_layout",
    "R.id.pingDelayTitle",
    "R.id.pktLossProTitle",
    "R.id.routerDelayTitle",
    "R.id.tvContent",
    "R.id.guideline",
    "R.drawable.file_icon_com",
    "R.drawable.file_icon_excel",
    "R.drawable.file_icon_mind",
    "R.drawable.file_icon_pdf",
    "R.drawable.file_icon_pic",
    "R.drawable.file_icon_ppt",
    "R.drawable.file_icon_txt",
    "R.drawable.file_icon_unknown",
    "R.drawable.file_icon_vid",
    "R.drawable.file_icon_word",
    // huawei hms core sdk
    "R.string.hms*",
    "R.string.connect_server_fail_prompt_toast",
    "R.string.getting_message_fail_prompt_toast",
    "R.string.no_available_network_prompt_toast",
    "R.string.third_app_*",
    "R.string.upsdk_*",
    "R.layout.hms*",
    "R.layout.upsdk_*",
    "R.drawable.upsdk*",
    "R.color.upsdk*",
    "R.dimen.upsdk*",
    "R.style.upsdk*",
    "R.string.agc*"
]
```

### 1.2 SDK组成
- Demo 样例工程
- Docs   接入文档、API文档以及其他参考文档
- SDK    包含所有SDK代码的本地maven

### 1.3 集成步骤
- 将SDK中的repo文件夹整体复制到你的项目根目录下
- 在主工程的build.gradle文件中，添加
```groovy
android {
	...
    defaultConfig {
		...
        minSdkVersion 21
        multiDexEnabled true
		...
    }
	...
	compileOptions {
        sourceCompatibility = 1.8
        targetCompatibility = 1.8
    }
    packagingOptions {
        exclude 'AndroidManifest.xml'
    }
	...
}
```

* 在需要依赖会议SDK的module的build.gradle文件中，添加

```groovy
repositories {
    maven {
        url "file://${new File(project.rootProject.rootDir, 'repo').getAbsolutePath()}"
    }
    maven {
        allowInsecureProtocol = true
        url "https://maven.columbus.heytapmobi.com/repository/OpenCapability/"
	credentials {
            username "ocuser"
            password "3dca1351358f49aeaf5af516ffd05a7c8e0cbd56"
	}
    }
}
dependencies {
	...
	//wemeet_version为使用sdk版本
	implementation "com.tencent.wemeet:tm-android-sdk:${wemeet_version}"
	...
}
```



## 2. Android接入特殊步骤

Android SDK初始化除在《TencentMeetingSDK（TMSDK）接口参考文档》中已有说明的 `TMSDK.initialize` 外，还需要在Application的`onCreate` 下 调用 `initOnApplicationCreate` ，这个步骤主要用于设置context以及必要的状态，不会进行真正的初始化操作（注意这个方法initOnApplicationCreate必须在所有进程初始化）

**为支持隐私合规,已在3.6.200版本提供支持隐私合规的接入方式**
- initOnApplicationCreate在原有基础上提供重载方法
```
    //原有方式，不支持隐私合规
    TMSDK.initOnApplicationCreate(Application application); 

    //支持隐私合规的接入方式，此时`isPrivacyNeedGrant`参数需要传true，表示开启隐私合规检查。如果此参数为false，则表示SDK不支持隐私合规
    TMSDK.initOnApplicationCreate(Application application, boolean isPrivacyNeedGrant); 
```
- 增加用户同意SDK隐私授权接口
```
    //如果initOnApplicationCreate传入参数`isPrivacyNeedGrant`为true，必须调用notifyPrivacyGranted后方可正常初始化SDK,否则会导致SDK异常
    TMSDK.notifyPrivacyGranted(Context context);
```
- 接入展示
```kotlin
//DemoApplication
@Override
public void onCreate() {

  super.onCreate();
  TMSDK.initOnApplicationCreate(this, true);
}

//DemoActivity
//首次启动，在用户同意隐私授权后的适当时机调用：
mBtnAgree.setOnClickListener(
        v -> {
            TMSDK.notifyPrivacyGranted(DemoActivity.this);
            TMSDK.INSTANCE.initialize(initParams, sdkCallback)
            ...
        }
);
```

自定义通知栏样式：

```kotlin
 val notificationConfig = NotificationConfig.Builder()
            .setNotificationLargeIconResId(R.mipmap.ic_logo_round)
            .setNotificationSmallIconResId(R.mipmap.ic_logo_round)
            .showNotificationLargeIcon(true)
            .build()
 TMSDK.setMeetingNotificationConfig(notificationConfig)
```

如果您的应用开启了邀请(enableInviteCallback)、会议信息(enableMeetingInfoCallback)、添加成员(enableInviteUsersCallback)等回调，并打算在收到这些回调时展示一个新的Activity，您需要给这个Activity设置如下所示的'taskAffinity'属性，并给启动该Activity的intent中添加FLAG_ACTIVITY_NEW_TASK，以保证该Activity跟会中Activity处于同一个任务栈，在关闭该Activity时才能正常返回会中界面，如果没有正确地设置'taskAffinity'属性和flag，该Activity将启动在应用默认的任务栈，关闭Activity时将显示默认任务栈中最顶层的Activity，不会自动回到会中。
```
 // AndroidManifest.xml
 ...
 android:taskAffinity=".meeting.inmeeting.InMeetingActivity" // SDK Version < 3.12.3
 android:taskAffinity="com.tencent.wemeet.tmsdk.meeting.inmeeting.InMeetingActivity" // SDK Version >= 3.12.3
 ...

 // 邀请、会议信息、添加成员等回调
 ...
 intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
 ...
```
