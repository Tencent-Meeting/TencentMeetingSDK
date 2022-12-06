# FAQ

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
    移除glide  wemeet-kapt 
    移除bugly  tm-bugly-sdk 
```groovy
    implementation "com.tencent.wemeet: ${wemeet_version}" {
        exclude group: 'com.tencent.wemeet.third-party', module: 'tbssdk-dynamic'
        exclude group: 'com.tencent.wemeet.third-party', module: 'imsdk'
	exclude group: 'com.github.bumptech.glide'
	exclude module: 'wemeet-kapt'
	exclude module: 'tm-bugly-sdk'
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
