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
      移除glide、wemeet-kapt。**仅在某个依赖项存在重复class问题的情况下才添加对应的exclude条件，请不要将以下内容直接全部粘贴到您的项目代码中！**

  ```groovy
      implementation ('com.tencent.wemeet:tm-android-sdk:${wemeet_version}') { //注意：这里的${wemeet_version}需要替换为具体的sdk版本号
          exclude group: 'com.tencent.wemeet.third-party', module: 'imsdk'
  	    exclude group: 'com.github.bumptech.glide'
  	    exclude module: 'wemeet-kapt'
  	    exclude group: 'com.tencent.wemeet.third-party', module: 'tbssdk' //注意： (版本 >= 3.12.100)用这个
  	    exclude group: 'com.tencent.liteav'
      }
  ```

  为兼容3.12.100之前的版本，请使用如下的方法排除重复的依赖。**仅在某个依赖项存在重复class问题的情况下才添加对应的exclude条件，请不要将以下内容直接全部粘贴到您的项目代码中！**

  ```groovy
      implementation ('com.tencent.wemeet:tm-android-sdk:${wemeet_version}') { //注意：这里的${wemeet_version}需要替换为具体的sdk版本号
          exclude group: 'com.tencent.wemeet.third-party', module: 'imsdk'
  	    exclude group: 'com.github.bumptech.glide'
  	    exclude module: 'wemeet-kapt'
  	    exclude group: 'com.tencent.wemeet.third-party', module: 'tbssdk-dynamic' //注意：（版本 < 3.12.100）用这个
  	    exclude group: 'com.tencent.liteav'
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

  - 应用异常退出后，切换账号登录异常或者登录的账号信息错误

  > 如果登录的账号发生切换，请主动调用登出接口以清空登录态，再重新尝试登录。

  - Q:收到分享回调显示透明activity但是背景activity显示的不是会中界面
  - A:请联系技术支持

  - Q:在会中界面点击管理成员发生crash，错误为java.lang.ClassNotFoundException: Didn't find class "android.support.v7.widget.RecyclerView$ItemDecoration"
  - A:在gradle.properties中添加android.enableJetifier=true
