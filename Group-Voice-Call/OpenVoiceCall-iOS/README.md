# Open Voice Call iOS for Swift

*其他语言版本： [简体中文](README.zh.md)*

The Open Voice Call iOS for Swift Sample App is an open-source demo that will help you get voice chat integrated directly into your iOS applications using the Agora Voice SDK.

With this sample app, you can:

- Join / leave channel
- Mute / unmute audio
- Switch speaker

A tutorial demo can be found here: [Agora-iOS-Voice-Tutorial-Swift-1to1](https://github.com/AgoraIO/Agora-iOS-Voice-Tutorial-Swift-1to1)

You can find demo for Android here:

- [OpenVoiceCall-Android](https://github.com/AgoraIO/OpenVoiceCall-Android)

## Running the App
First, create a developer account at [Agora.io](https://dashboard.agora.io/signin/), and obtain an App ID. Update "KeyCenter.swift" with your App ID.

```
static let AppId: String = "Your App ID"
```

Next, download the **Agora Voice SDK** from [Agora.io SDK](https://www.agora.io/en/blog/download/). Unzip the downloaded SDK package and copy the **libs/AgoraAudioKit.framework** to the "OpenVoiceCall" folder in project.

Finally, Open OpenVoiceCall.xcodeproj, connect your iPhone／iPad device, setup your development signing and run.

## Developer Environment Requirements
* XCode 8.0 +
* Real devices (iPhone or iPad)
* iOS simulator is NOT supported

## Connect Us

- You can find full API document at [Document Center](https://docs.agora.io/en/)
- You can file bugs about this demo at [issue](https://github.com/AgoraIO/OpenVoiceCall-iOS/issues)

## License

The MIT License (MIT).
