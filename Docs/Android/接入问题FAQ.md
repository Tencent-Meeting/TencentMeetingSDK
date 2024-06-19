- # FAQ

  - Q:接入sdk后，出现运行时异常：AAPT: error: style attribute 'android:attr/windowSplashScreenAnimatedIcon' not found.

  ```
  A: compileSdkVersion 31及以上
  ```

  - Q:接入sdk后，出现运行时异常：Execution failed for task ':baselibrary:compileDebugJavaWithJavac'. > javax/xml/bind/JAXBException

  ```
  A:implementation "javax.xml.bind:jaxb-api:2.3.1"
  ```

  - Q:接入sdk后，出现运行时异常：java.lang.UnsatisfiedLinkError
  - A:目前会议的so只支持armeabi-v7a和arm64-v8a的架构

  ```
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
      移除glide。**仅在某个依赖项存在重复class问题的情况下才添加对应的exclude条件，请不要将以下内容直接全部粘贴到您的项目代码中！**

  ```groovy
      implementation ('com.tencent.wemeet:tm-android-sdk:${wemeet_version}') { //注意：这里的${wemeet_version}需要替换为具体的sdk版本号
          exclude group: 'com.tencent.wemeet.third-party', module: 'imsdk'
          exclude group: 'com.github.bumptech.glide'
          exclude group: 'com.tencent.wemeet.third-party', module: 'tbs-sdk-overseas' //注意： (版本 >= 3.21.100)用这个
          exclude group: 'com.tencent.wemeet.third-party', module: 'tbssdk' //注意： (版本 >= 3.12.100)用这个
          exclude group: 'com.tencent.wemeet.third-party', module: 'tbssdk-dynamic' //注意：（版本 < 3.12.100）用这个
          exclude group: 'com.tencent.liteav'
      }
  ```

  ​	**如果集成SDK后出现mmkv组件版本冲突，原因为 mmkv库与会议SDK使用的mmkv-static不兼容导致，请使用mmkv-static，mmkv-static版本尽量使用新版**
  
  - Q: 重复的class报错，但重复类的包名为com.tencent.thumbplayer，且冲突库为com.tencent.liteav.LiteAVSDK_Player:
    A: 请更新SDK库和LiteAVSDK_Player库版本，同时满足以下版本要求:
  
  ```
  会议SDK版本>=3.21.200;
  LiteAVSDK_player版本>=11.7.0.13910;
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
  
  - 应用异常退出后，切换账号登录异常或者登录的账号信息错误
  
  > 如果登录的账号发生切换，请主动调用登出接口以清空登录态，再重新尝试登录。
  
  - Q:收到邀请或分享回调后显示透明activity但是背景activity显示的不是会中界面，或者关闭activity后没有回到会中界面
  - A:请确保activity设置了如下所示的taskAffinity属性，并在启动activity时调用intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)，如果仍然无法解决问题，请联系技术支持
  ```
          android:taskAffinity=".meeting.inmeeting.InMeetingActivity" // SDK Version < 3.12.3
          android:taskAffinity="com.tencent.wemeet.tmsdk.meeting.inmeeting.InMeetingActivity" // SDK Version >= 3.12.3
  ```
  
  - Q:在会中界面点击管理成员发生crash，错误为java.lang.ClassNotFoundException: Didn't find class "android.support.v7.widget.RecyclerView$ItemDecoration"
  
  - A:在gradle.properties中添加android.enableJetifier=true
  
    
  - Q: 在Android 11以上设备中，无法使用蓝牙设备怎么处理
  
  - A: 蓝牙权限配置问题，一般是蓝牙权限声明的AndroidManifest.xml文件中，多加了maxSdkVersion的限制。需要去除该限制。
  
    ```
    <uses-permission android:name="android.permission.BLUETOOTH"/>  //去除android:maxSdkVersion="30"
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>  //去除android:maxSdkVersion="30"
    ```
  
  - Q: 接入SDK后编译报错，报错信息包含以下内容：
    Resource compilation failed (Failed to compile values resource file path/to/values.xml. Cause: java.nio.file.InvalidPathException: Illegal char <:> at index 48: path/to/values.xml).
  
  - A: 项目中的某个attr跟SDK重复定义了，由于AGP存在bug，这里的报错信息跟attr重复定义并无关系，可以执行aapt2 compile path/to/values.xml -o compiled/，该命令的输出中将包含重复定义的attr，修改该attr名称避免重复问题即可解决。
  
