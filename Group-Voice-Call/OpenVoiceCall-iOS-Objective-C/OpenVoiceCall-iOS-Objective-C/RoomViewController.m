//
//  RoomViewController.m
//  OpenVoiceCall-OC
//
//  Created by CavanSu on 2017/9/18.
//  Copyright © 2017 Agora. All rights reserved.
//

#import "RoomViewController.h"
#import <AgoraAudioKit/AgoraRtcEngineKit.h>
#import "AppID.h"
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
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:[AppID appID] delegate:self];
    [self.agoraKit setDefaultAudioRouteToSpeakerphone:YES];
    [self.agoraKit joinChannelByToken:nil channelId:self.channelName info:nil uid:0 joinSuccess:nil];
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
    [self.agoraKit muteLocalAudioStream:sender.selected];
}

- (IBAction)clickHungUpButton:(UIButton *)sender {
    __weak typeof(RoomViewController) *weakself = self;
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
// self joined success
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Self join channel with uid:%lu", (unsigned long)uid]];
    [self.agoraKit setEnableSpeakerphone:YES];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Uid:%lu joined channel with elapsed:%ld", (unsigned long)uid, (long)elapsed]];
}

- (void)rtcEngineConnectionDidInterrupted:(AgoraRtcEngineKit *)engine {
    [self appendInfoToTableViewWithInfo:@"ConnectionDidInterrupted"];
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine {
    [self appendInfoToTableViewWithInfo:@"ConnectionDidLost"];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Error Code:%ld", (long)errorCode]];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Uid:%lu didOffline reason:%lu", (unsigned long)uid, (unsigned long)reason]];
}

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
