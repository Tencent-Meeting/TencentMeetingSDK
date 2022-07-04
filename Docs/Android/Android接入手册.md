
## 1. Android SDK 集成接入指南

### 1.1 版本环境提示
- 支持 minsdkVersion 21
- 使用Android Studio作为IDE
- 如果您还在使用android.support.*，建议您迁移到AndroidX，建议迁移前满足以下条件
	1. Android Studio 3.2及以上
	1. Gradle版本4.6及以上
	1. 项目编译版本30及以上
	1. NDK版本21及以上
- 迁移到Android X步骤
	1. 在Android studio中点击`Refactor > Migrate to AndroidX`，依照提示进行迁移即可。(迁移过程遇到问题可以参考官方文档)
	1. 通过反射取support包内class的代码，可以全局搜索android.support找到对应的位置手动名进行替换
	1. 如果项目中有对support库进行混淆配置，需要针对对应的AndroidX加上相应的混淆配置
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

```kotlin
@Override
public void onCreate() {
  super.onCreate();
  TMSDK.initOnApplicationCreate(this);
}
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

## 3. FAQ

- Q:接入sdk后，出现运行时异常：java.lang.UnsatisfiedLinkError
A:目前会议的so只支持armeabi-v7a和arm64-v8a的架构，需要检查是否做了以下配置
```groovy
android {
	...
    defaultConfig {
		...
        ndk {
          	//可以根据需求减少abi，但是不能增加其他abi
            setAbiFilters(['armeabi-v7a', 'arm64-v8a'])
        }
		...
    }
	...
}
```
- Q:遇到编译错误：Invoke-customs are only supported starting with Android O
A:请在build.gradle中添加：
```groovy
android {
	...
	compileOptions {
        sourceCompatibility = 1.8
        targetCompatibility = 1.8
    }
	...
}
```
- Q:重复class报错，目前会出现此类问题的主要以x5内核和imsdk下的文件为主

  A:执行./gradlew app:dependencies(window下执行gradlew app:dependencies)，对照输出依赖将sdk中的依赖排除出去，例如

```groovy
    implementation "com.tencent.wemeet: ${wemeet_version}" {
        exclude group: 'com.tencent.tbssdk', module: 'tbssdk'
        exclude group: 'com.tencent.wemeet', module: 'imsdk'
    }
```
- Q:javax.net.ssl.SSLHandshakeException: java.security.cert.CertPathValidatorException: Trust anchor for certification path not found.
  A:

  -  在src/main/res/xml下新增network_security_config.xml

  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  	<network-security-config>
  		<domain-config cleartextTrafficPermitted="true">
  			<domain includeSubdomains="true">需要开放的域名</domain>
  		</domain-config>
  	</network-security-config>
  
  ```
  - 然后在AndroidManifest.xml中设置networkSecurityConfig

  ```xml
  <manifest ... >
        <application android:networkSecurityConfig="@xml/network_security_config">
            ...
        </application>
    </manifest>
  ```

  - 其他字段含义可以参考Android官网：https://developer.android.com/training/articles/security-config?hl=zh-cn
- Q:Didn't find class "androidx.localbroadcastmanager.content.LocalBroadcastManager"  && java.lang.NoClassDefFoundError: Failed resolution of: Landroidx/swiperefreshlayout/widget/CircularProgressDrawable; 当出现这个两个类找不到的时候，可能是com.google.android.material:material的版本过高导致的，
- A:在gradle的dependencies添加下面依赖：
```
        implementation "androidx.swiperefreshlayout:swiperefreshlayout:1.0.0"
        implementation 'androidx.localbroadcastmanager:localbroadcastmanager:1.0.0'
```	
- Q:在会中收到邀请或者分享回调后显示邀请或者分享界面异常怎么处理
- A:
```
       在邀请或者分享的activity里面添加 android:taskAffinity=".meeting.inmeeting.InMeetingActivity"
       在启动邀请或者分享界面离添加 intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
```	
- 应用异常退出后，切换账号登录异常或者登录的账号信息错误
> 如果登录的账号发生切换，请主动调用登出接口以清空登录态，再重新尝试登录。

