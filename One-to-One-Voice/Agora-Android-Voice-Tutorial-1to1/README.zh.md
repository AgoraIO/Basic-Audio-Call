# Agora Android Voice Tutorial - 1to1

*Read this in other languages: [English](README.md)*

这个开源示例项目演示了如何快速集成 Agora 音频 SDK，实现1对1音频通话。

在这个示例项目中包含了以下功能：

- 加入通话和离开通话；
- 静音和解除静音；
- 切换扬声器和听筒；

你可以在这里查看进阶版的示例项目：[OpenVoiceCall-Android](https://github.com/AgoraIO/Basic-Audio-Call/tree/master/Group-Voice-Call/OpenVoiceCall-Android)

## 运行示例程序
**首先**在 [Agora.io 注册](https://dashboard.agora.io/cn/signup/) 注册账号，并创建自己的测试项目，获取到 AppID。你可以在你的项目页面生成一个临时的Token (生成的Token只能用于加入指定的频道)，将 AppID 和 Token 填写进 "app/src/main/res/values/strings.xml"

```
<!-- PLEASE KEEP THIS App ID IN SAFE PLACE -->
<!-- Get your own App ID at https://dashboard.agora.io/ -->
<!-- After you entered the App ID, remove <##> outside of Your App ID -->
<!-- For formal released project, please use Security Keys/Token
    https://docs.agora.io/en/Video/token?platform=All%20Platforms -->
<string name="agora_app_id"><#YOUR APP ID#></string>
<!-- Please leave it if not enable App Certificate -->
<!-- You can generate a temporary token at https://dashboard.agora.io/projects -->
<string name="agora_access_token">#YOUR ACCESS TOKEN#</string>
```

**然后**是集成 Agora 音频 SDK ，集成方式有以下两种：

- 首选集成方式：

在项目对应的模块的 "app/build.gradle" 文件的依赖属性中加入通过 JCenter 自动集成 Agora 音频 SDK 的地址：

```
implementation 'io.agora.rtc:voice-sdk:2.4.1'
```

( 如果要在自己的应用中集成 Agora 音频 SDK，添加链接地址是最重要的一步。）

- 次选集成方式：

第一步: 在 [Agora.io SDK](https://www.agora.io/cn/download/) 下载 **语音通话 + 直播 SDK**，解压后将其中的 **libs** 文件夹下的 ***.jar** 复制到本项目的 **app/libs** 下，其中的 **libs** 文件夹下的 **arm64-v8a**/**x86**/**armeabi-v7a** 复制到本项目的 **app/src/main/jniLibs** 下。

第二步: 在本项目的 "app/build.gradle" 文件依赖属性中添加如下依赖关系：

```
compile fileTree(dir: 'libs', include: ['*.jar'])
```

**最后**用 Android Studio 打开该项目，连上设备，编译并运行。

也可以使用 `Gradle` 直接编译运行。

## 运行环境
- Android Studio 3.0 +
- 真实 Android 设备 (Nexus 5X 或者其它设备)
- 部分模拟器会存在功能缺失或者性能问题，所以推荐使用真机

## 联系我们
- 如果你遇到了困难，可以先参阅 [常见问题](https://docs.agora.io/cn/faq)
- 如果你想了解更多官方示例，可以参考 [官方SDK示例](https://github.com/AgoraIO)
- 如果你想了解声网SDK在复杂场景下的应用，可以参考 [官方场景案例](https://github.com/AgoraIO-usecase)
- 如果你想了解声网的一些社区开发者维护的项目，可以查看 [社区](https://github.com/AgoraIO-Community)
- 完整的 API 文档见 [文档中心](https://docs.agora.io/cn/)
- 若遇到问题需要开发者帮助，你可以到 [开发者社区](https://rtcdeveloper.com/) 提问
- 如果需要售后技术支持, 你可以在 [Agora Dashboard](https://dashboard.agora.io) 提交工单
- 如果发现了示例代码的 bug，欢迎提交 [issue](https://github.com/AgoraIO/Basic-Audio-Call/issues)

## 代码许可
The MIT License (MIT).
