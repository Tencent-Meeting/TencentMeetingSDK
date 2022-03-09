# FAQ

## ts中是用wemeet sdk
1.项目中引入node-loader
2.添加配置
      {
        test: /\.node$/,
        loader: 'node-loader'
      }
  注意检查是否和其它配置冲突
3.npm install 或者 yarn install
4.将TMSDK.framework拷贝至./node_modules/electron/dist/Electron.app/Contents/Frameworks/   (可以通过自定义脚本实现，参考electron demo)
5.import * as wemeet_sdk from 'wemeet_electron_sdk.node的目录'
6.调用sdk函数，如wemeet_sdk.GetSDKVersion()
