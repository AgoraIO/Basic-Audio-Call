//
//  VoiceChatViewController.swift
//  Agora iOS Voice Tutorial
//
//  Created by GongYuhua on 2017/4/10.
//  Copyright © 2017年 Agora. All rights reserved.
//

import UIKit
import AgoraAudioKit

class VoiceChatViewController: UIViewController {

    @IBOutlet weak var controlButtonsView: UIView!
    
    var agoraKit: AgoraRtcEngineKit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeAgoraEngine()
        joinChannel()
    }
    
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: nil)
    }
    
    func joinChannel() {
        agoraKit.joinChannel(byToken: nil, channelId: "demoChannel", info:nil, uid:0) {[unowned self] (sid, uid, elapsed) -> Void in
            // Joined channel "demoChannel"
            self.agoraKit.setEnableSpeakerphone(true)
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        leaveChannel()
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        hideControlButtons()
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func hideControlButtons() {
        controlButtonsView.isHidden = true
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction func didClickSwitchSpeakerButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.setEnableSpeakerphone(sender.isSelected)
    }
}
