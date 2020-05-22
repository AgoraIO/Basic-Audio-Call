//
//  RoomViewController.swift
//  OpenVoiceCall
//
//  Created by GongYuhua on 16/8/22.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit
import AgoraRtcKit

protocol RoomVCDelegate: class {
    func roomVCNeedClose(_ roomVC: RoomViewController)
}

class RoomViewController: UIViewController {
    
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var muteAudioButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    
    var roomName: String!
    weak var delegate: RoomVCDelegate?
    
    // create a reference for the Agora RTC engine
    fileprivate var agoraKit: AgoraRtcEngineKit!
    fileprivate var logs = [String]()
    
    // create a property for the Audio Muted state
    fileprivate var audioMuted = false {
        didSet {
            // update the audio button graphic whenever the audioMuted (bool) changes
            muteAudioButton?.setImage(UIImage(named: audioMuted ? "btn_mute_blue" : "btn_mute"), for: .normal)
            // use the audioMuted (bool) to mute/unmute the local audio stream
            agoraKit.muteLocalAudioStream(audioMuted)
        }
    }
    // create a property for the Speaker Mode state
    fileprivate var speakerEnabled = true {
        didSet {
            // update the speaker button graphics whenever the speakerEnabled (bool) changes
            speakerButton?.setImage(UIImage(named: speakerEnabled ? "btn_speaker_blue" : "btn_speaker"), for: .normal)
            speakerButton?.setImage(UIImage(named: speakerEnabled ? "btn_speaker" : "btn_speaker_blue"), for: .highlighted)
            // use the speakerEnabled (bool) to enable/disable speakerPhone
            agoraKit.setEnableSpeakerphone(speakerEnabled)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomNameLabel.text = "\(roomName!)"
        logTableView.rowHeight = UITableView.automaticDimension
        logTableView.estimatedRowHeight = 25
        loadAgoraKit()
    }
    
    @IBAction func doMuteAudioPressed(_ sender: UIButton) {
        audioMuted = !audioMuted
    }
    
    @IBAction func doSpeakerPressed(_ sender: UIButton) {
        speakerEnabled = !speakerEnabled
    }
    
    @IBAction func doClosePressed(_ sender: UIButton) {
        leaveChannel()
    }
}

private extension RoomViewController {
    func append(log string: String) {
        guard !string.isEmpty else {
            return
        }
        
        logs.append(string)
        
        var deleted: String?
        if logs.count > 200 {
            deleted = logs.removeFirst()
        }
        
        updateLogTable(withDeleted: deleted)
    }
    
    func updateLogTable(withDeleted deleted: String?) {
        guard let tableView = logTableView else {
            return
        }
        
        let insertIndexPath = IndexPath(row: logs.count - 1, section: 0)
        
        tableView.beginUpdates()
        if deleted != nil {
            tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
        tableView.insertRows(at: [insertIndexPath], with: .none)
        tableView.endUpdates()
        
        tableView.scrollToRow(at: insertIndexPath, at: .bottom, animated: false)
    }
}

//MARK: - table view
extension RoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath) as! LogCell
        cell.set(log: logs[(indexPath as NSIndexPath).row])
        return cell
    }
}

//MARK: - agora engine
private extension RoomViewController {
    func loadAgoraKit() {
        ///  Initialize the RTC Engine in two basic steps:
        
        // Step 1: get the instance of the engine using the `AppId`
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        
        // Step 2: join the channel using the `Token` and `roomName`
        let code = agoraKit.joinChannel(byToken: KeyCenter.Token, channelId: roomName, info: nil, uid: 0, joinSuccess: nil)
        
        // check if channel join failed
        if code != 0 {
            DispatchQueue.main.async(execute: {
                self.append(log: "Join channel failed: \(code)")
            })
        }
    }
    
    func leaveChannel() {
        // leaving the Agora channel
        agoraKit.leaveChannel(nil)
        delegate?.roomVCNeedClose(self)
    }
}

//MARK: Agora Delegate
extension RoomViewController: AgoraRtcEngineDelegate {
    
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
    func rtcEngineConnectionDidInterrupted(_ engine: AgoraRtcEngineKit) {
        append(log: "Connection Interrupted")
    }
    
    /** Occurs when the SDK cannot reconnect to Agora's edge server 10 seconds after its connection to the server is interrupted.
    *  See the description above to compare this method to rtcEngineConnectionDidInterrupted.
    *
    * @param engine AgoraRtcEngineKit object.
    */
    func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        append(log: "Connection Lost")
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
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        append(log: "Occur error: \(errorCode.rawValue)")
    }
    
    /** This method handles event for the local user joins a specified channel.
    *
    *  @param engine  - AgoraRtcEngineKit object.
    *  @param channel - Channel name.
    *  @param uid     - User ID. If the `uid` is specified in the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, the specified user ID is returned. If the user ID is not specified when the joinChannel method is called, the server automatically assigns a `uid`.
    *  @param elapsed - Time elapsed (ms) from the user calling the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK triggers this callback.
    * - */
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        append(log: "Did joined channel: \(channel), with uid: \(uid), elapsed: \(elapsed)")
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
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        append(log: "Did joined of uid: \(uid)")
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
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        append(log: "Did offline of uid: \(uid), reason: \(reason.rawValue)")
    }
    
    /** Reports the audio quality of the remote user.
    *
    *  @param engine  - AgoraRtcEngineKit object.
    *  @param uid     - User ID of the speaker.
    *  @param quality - Audio quality of the user, see [AgoraNetworkQuality](https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraNetworkQuality.html).
    *  @param delay - Time delay (ms) of the audio packet sent from the sender to the receiver, including the time delay from audio sampling pre-processing, transmission, and the jitter buffer.
    *  @param lost - Packet loss rate (%) of the audio packet sent from the sender to the receiver.
    * - */
    func rtcEngine(_ engine: AgoraRtcEngineKit, audioQualityOfUid uid: UInt, quality: AgoraNetworkQuality, delay: UInt, lost: UInt) {
        append(log: "Audio Quality of uid: \(uid), quality: \(quality.rawValue), delay: \(delay), lost: \(lost)")
    }
  
    /** Occurs when a method is executed by the SDK.
    *
    *  @param engine  - AgoraRtcEngineKit object.
    *  @param api - The method executed by the SDK.
    *  @param error - The error code ([AgoraErrorCode](https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html)) returned by the SDK when the method call fails. If the SDK returns 0, then the method call succeeds.
    *  @param result - The result of the method call.
    * - */
    func rtcEngine(_ engine: AgoraRtcEngineKit, didApiCallExecute api: String, error: Int) {
        append(log: "Did api call execute: \(api), error: \(error)")
    }
}
