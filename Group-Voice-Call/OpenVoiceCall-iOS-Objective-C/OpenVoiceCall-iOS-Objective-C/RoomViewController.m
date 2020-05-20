//
//  RoomViewController.m
//  OpenVoiceCall-OC
//
//  Created by CavanSu on 2017/9/18.
//  Copyright © 2017 Agora. All rights reserved.
//

#import "RoomViewController.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "KeyCenter.h"
#import "InfoCell.h"
#import "InfoModel.h"

@interface RoomViewController () <UITableViewDataSource, UITableViewDelegate, AgoraRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *infoArray;
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateViews];
    [self loadAgoraKit];
}

#pragma mark- setupViews
- (void)updateViews {
    self.roomNameLabel.text = self.channelName;
    self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark- initAgoraKit
- (void)loadAgoraKit {
    ///  Initialize the RTC Engine in three basic steps:
    
    // Step 1: get the instance of the engine using the AppId
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:[KeyCenter AppId] delegate:self];
    
    // Step 2: route the audio to speaker phone
    [self.agoraKit setDefaultAudioRouteToSpeakerphone:YES];
    
    // Step 3: join the channel.  In this demo, we do not use a token, thus it is nil
    // If the App certificate is set up, pass the token to the first parameter
    [self.agoraKit joinChannelByToken:[KeyCenter Token] channelId:self.channelName info:nil uid:0 joinSuccess:nil];
}

#pragma mark- append info to tableView to display
- (void)appendInfoToTableViewWithInfo:(NSString *)infoStr {
    InfoModel *model = [InfoModel modelWithInfoStr:infoStr];
    [self.infoArray insertObject:model atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark- click buttons
- (IBAction)clickMuteButton:(UIButton *)sender {
    // Muting the local audio input
    [self.agoraKit muteLocalAudioStream:sender.selected];
}

- (IBAction)clickHungUpButton:(UIButton *)sender {
    __weak typeof(RoomViewController) *weakself = self;
    // Hang up meaning leaving the channel.  You may assign some action after
    // leaving the channel
    [self.agoraKit leaveChannel:^(AgoraChannelStats *stat) {
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)clickSpeakerButton:(UIButton *)sender {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sender.selected = NO;
    }
    else {
        [self.agoraKit setEnableSpeakerphone:!sender.selected];
    }
}

#pragma mark- <AgoraRtcEngineDelegate>

/** This method handles event for the local user joins a specified channel.
 *
 *  @param engine  - AgoraRtcEngineKit object.
 *  @param channel - Channel name.
 *  @param uid     - User ID. If the `uid` is specified in the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, the specified user ID is returned. If the user ID is not specified when the joinChannel method is called, the server automatically assigns a `uid`.
 *  @param elapsed - Time elapsed (ms) from the user calling the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK triggers this callback.
 * - */
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Self join channel with uid:%lu", (unsigned long)uid]];
    [self.agoraKit setEnableSpeakerphone:YES];
}


/** This method handles event for a remote user or host joins a channel.
 * - Communication profile: This callback notifies the app that another user joins the channel. If other users are already in the channel, the SDK also reports to the app on the existing users.
 * - Live-broadcast profile: This callback notifies the app that a host joins the channel. If other hosts are already in the channel, the SDK also reports to the app on the existing hosts. Agora recommends limiting the number of hosts to 17.

 * The SDK triggers this callback under one of the following circumstances:
 * - A remote user/host joins the channel by calling the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method.
 * - A remote user switches the user role to the host by calling the [setClientRole]([AgoraRtcEngineKit setClientRole:]) method after joining the channel.
 * - A remote user/host rejoins the channel after a network interruption.
 * - A host injects an online media stream into the channel by calling the [addInjectStreamUrl]([AgoraRtcEngineKit addInjectStreamUrl:config:]) method.

 * *Note:**

 * Live-broadcast profile:
 *
 * * The host receives this callback when another host joins the channel.
 * * The audience in the channel receives this callback when a new host joins the channel.
 * * When a web application joins the channel, the SDK triggers this callback as long as the web application publishes streams.
 *
 * @param engine  - AgoraRtcEngineKit object.
 * @param uid     - ID of the user or host who joins the channel. If the `uid` is specified in the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, the specified user ID is returned. If the `uid` is not specified in the joinChannelByToken method, the Agora server automatically assigns a `uid`.
 * @param elapsed - Time elapsed (ms) from the local user calling the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) or [setClientRole]([AgoraRtcEngineKit setClientRole:]) method until the SDK triggers this callback.
*/
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Uid:%lu joined channel with elapsed:%ld", (unsigned long)uid, (long)elapsed]];
}

/** Occurs when the connection between the SDK and the server is interrupted.
 *
 * **DEPRECATED** from v2.3.2. Use the [connectionChangedToState]([AgoraRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callback instead.
 *
 * The SDK triggers this callback when it loses connection with the server for more than four seconds after a connection is established.
 *
 * This callback is different from [rtcEngineConnectionDidLost]([AgoraRtcEngineDelegate rtcEngineConnectionDidLost:]):
 *
 * - The SDK triggers this callback when it loses connection with the server for more than four seconds after it joins the channel.
 * - The SDK triggers the [rtcEngineConnectionDidLost when it loses connection with the server for more than 10 seconds, regardless of whether it joins the channel or not.
 *
 * If the SDK fails to rejoin the channel 20 minutes after being disconnected from Agora's edge server, the SDK stops rejoining the channel.
 *
 *  @param engine - AgoraRtcEngineKit object.
 */
- (void)rtcEngineConnectionDidInterrupted:(AgoraRtcEngineKit *)engine {
    [self appendInfoToTableViewWithInfo:@"ConnectionDidInterrupted"];
}


/** Occurs when the SDK cannot reconnect to Agora's edge server 10 seconds after its connection to the server is interrupted.
 *  See the description above to compare this method to rtcEngineConnectionDidInterrupted.
 *
 * @param engine AgoraRtcEngineKit object.
 */
- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine {
    [self appendInfoToTableViewWithInfo:@"ConnectionDidLost"];
}

/** Reports an error during SDK runtime.
 *
 * In most cases, the SDK cannot fix the issue and resume running. The SDK requires the app to take action or informs the user about the issue.
 *
 * For example, the SDK reports an AgoraErrorCodeStartCall = 1002 error when failing to initialize a call. The app informs the user that the call initialization failed and invokes the [leaveChannel]([AgoraRtcEngineKit leaveChannel:]) method to leave the channel.
 *
 *  @param engine   - AgoraRtcEngineKit object
 *  @param errorCode - Error code: AgoraErrorCode
 */
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Error Code:%ld", (long)errorCode]];
}


/** Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel. Same as [userOfflineBlock]([AgoraRtcEngineKit userOfflineBlock:]).
 *
 * There are two reasons for users to be offline:
 *
 * - Leave a channel: When the user/host leaves a channel, the user/host sends a goodbye message. When the message is received, the SDK assumes that the user/host leaves a channel.
 * - Drop offline: When no data packet of the user or host is received for a certain period of time (20 seconds for the Communication profile, and more for the Live-broadcast profile), the SDK assumes that the user/host drops offline. Unreliable network connections may lead to false detections, so Agora recommends using a signaling system for more reliable offline detection.
 *
 *  @param engine - AgoraRtcEngineKit object.
 *  @param uid   - ID o -f the user or host who leaves a channel or goes offline.
 *  @param reason - Reason why the user goes offline, see AgoraUserOfflineReason.
 */
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Uid:%lu didOffline reason:%lu", (unsigned long)uid, (unsigned long)reason]];
}

/** Occurs when the local audio route changes.
 *
 * The SDK triggers this callback when the local audio route switches to an earpiece, speakerphone, headset, or Bluetooth device.
 *
 *  @param engine  - AgoraRtcEngineKit object.
 *  @param routing - Audio route: AgoraAudioOutputRouting.
 */
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioRouteChanged:(AgoraAudioOutputRouting)routing {
    switch (routing) {
        case AgoraAudioOutputRoutingDefault:
            NSLog(@"AgoraRtc_AudioOutputRouting_Default");
            break;
        case AgoraAudioOutputRoutingHeadset:
            NSLog(@"AgoraRtc_AudioOutputRouting_Headset");
            break;
        case AgoraAudioOutputRoutingEarpiece:
            NSLog(@"AgoraRtc_AudioOutputRouting_Earpiece");
            break;
        case AgoraAudioOutputRoutingHeadsetNoMic:
            NSLog(@"AgoraRtc_AudioOutputRouting_HeadsetNoMic");
            break;
        case AgoraAudioOutputRoutingSpeakerphone:
            NSLog(@"AgoraRtc_AudioOutputRouting_Speakerphone");
            break;
        case AgoraAudioOutputRoutingLoudspeaker:
            NSLog(@"AgoraRtc_AudioOutputRouting_Loudspeaker");
            break;
        case AgoraAudioOutputRoutingHeadsetBluetooth:
            NSLog(@"AgoraRtc_AudioOutputRouting_HeadsetBluetooth");
            break;
        default:
            break;
    }
}

#pragma mark- <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InfoCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    InfoModel *model = self.infoArray[indexPath.row];
    cell.model = model;
    return cell;
}

#pragma mark- <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InfoModel *model = self.infoArray[indexPath.row];
    return model.height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

#pragma mark- others
- (NSMutableArray *)infoArray {
    if (!_infoArray) {
        _infoArray = [NSMutableArray array];
    }
    return _infoArray;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
