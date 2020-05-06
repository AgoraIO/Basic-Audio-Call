package io.agora.openacall.model;

import android.content.Context;

import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Iterator;
import java.util.concurrent.ConcurrentHashMap;

public class MyEngineEventHandler {
    public MyEngineEventHandler(Context ctx, EngineConfig config) {
        this.mContext = ctx;
        this.mConfig = config;
    }

    private final EngineConfig mConfig;

    private final Context mContext;

    private final ConcurrentHashMap<AGEventHandler, Integer> mEventHandlerList = new ConcurrentHashMap<>();

    public void addEventHandler(AGEventHandler handler) {
        this.mEventHandlerList.put(handler, 0);
    }

    public void removeEventHandler(AGEventHandler handler) {
        this.mEventHandlerList.remove(handler);
    }

    final IRtcEngineEventHandler mRtcEventHandler = new IRtcEngineEventHandler() {
        private final Logger log = LoggerFactory.getLogger(this.getClass());

        /**
         * Occurs when a remote user (Communication)/host (Live Broadcast) joins the channel.
         *
         *     Communication profile: This callback notifies the app when another user joins the channel. If other users are already in the channel, the SDK also reports to the app on the existing users.
         *     Live Broadcast profile: This callback notifies the app when the host joins the channel. If other hosts are already in the channel, the SDK also reports to the app on the existing hosts. We recommend having at most 17 hosts in a channel
         *
         * The SDK triggers this callback under one of the following circumstances:
         *
         *     A remote user/host joins the channel by calling the joinChannel method.
         *     A remote user switches the user role to the host by calling the setClientRole method after joining the channel.
         *     A remote user/host rejoins the channel after a network interruption.
         *     The host injects an online media stream into the channel by calling the addInjectStreamUrl method.
         *
         * @param uid ID of the user or host who joins the channel.
         * @param elapsed Time delay (ms) from the local user calling joinChannel/setClientRole until this callback is triggered.
         */
        @Override
        public void onUserJoined(int uid, int elapsed) {
        }

        /**
         * Occurs when a remote user (Communication)/host (Live Broadcast) leaves the channel.
         *
         * There are two reasons for users to become offline:
         *
         *     Leave the channel: When the user/host leaves the channel, the user/host sends a goodbye message. When this message is received, the SDK determines that the user/host leaves the channel.
         *     Drop offline: When no data packet of the user or host is received for a certain period of time (20 seconds for the communication profile, and more for the live broadcast profile), the SDK assumes that the user/host drops offline. A poor network connection may lead to false detections, so we recommend using the Agora RTM SDK for reliable offline detection.
         *
         * @param uid ID of the user or host who leaves the channel or goes offline.
         * @param reason Reason why the user goes offline:
         *
         *     USER_OFFLINE_QUIT(0): The user left the current channel.
         *     USER_OFFLINE_DROPPED(1): The SDK timed out and the user dropped offline because no data packet was received within a certain period of time. If a user quits the call and the message is not passed to the SDK (due to an unreliable channel), the SDK assumes the user dropped offline.
         *     USER_OFFLINE_BECOME_AUDIENCE(2): (Live broadcast only.) The client role switched from the host to the audience.
         */
        @Override
        public void onUserOffline(int uid, int reason) {
            log.debug("onUserOffline " + (uid & 0xFFFFFFFFL) + " " + reason);

            // FIXME this callback may return times
            Iterator<AGEventHandler> it = mEventHandlerList.keySet().iterator();
            while (it.hasNext()) {
                AGEventHandler handler = it.next();
                handler.onUserOffline(uid, reason);
            }
        }

        /**
         * Reports the statistics of the RtcEngine once every two seconds.
         * @param stats RTC engine statistics: RtcStats.
         */
        @Override
        public void onRtcStats(RtcStats stats) {
        }

        /**
         * Reports which users are speaking and the speakers' volume, and whether the local user is speaking.
         *
         * This callback reports the IDs and volumes of the loudest speakers (at most 3) at the moment in the channel, and whether the local user is speaking.
         *
         * By default, this callback is disabled. You can enable it by calling the enableAudioVolumeIndication method. Once enabled, this callback is triggered at the set interval, regardless of whether a user speaks or not.
         *
         * The SDK triggers two independent onAudioVolumeIndication callbacks at one time, which separately report the volume information of the local user and all the remote speakers. For more information, see the detailed parameter descriptions.
         *
         * @param speakerInfos An array containing the user ID and volume information for each speaker: AudioVolumeInfo.
         *
         *     In the local user’s callback, this array contains the following members:
         *         uid = 0,
         *         volume = totalVolume, which reports the sum of the voice volume and audio-mixing volume of the local user, and
         *         vad, which reports the voice activity status of the local user.
         *
         *     In the remote speakers' callback, this array contains the following members:
         *         uid of each remote speaker,
         *         volume, which reports the sum of the voice volume and audio-mixing volume of each remote speaker, and
         *         vad = 0.
         *
         *     An empty speakers array in the callback indicates that no remote user is speaking at the moment.
         *
         * @param totalVolume Total volume after audio mixing. The value ranges between 0 (lowest volume) and 255 (highest volume).
         *
         *     In the local user’s callback, totalVolume is the sum of the voice volume and audio-mixing volume of the local user.
         *     In the remote speakers' callback, totalVolume is the sum of the voice volume and audio-mixing volume of all remote speakers.
         */
        @Override
        public void onAudioVolumeIndication(AudioVolumeInfo[] speakerInfos, int totalVolume) {
            if (speakerInfos == null) {
                // quick and dirty fix for crash
                // TODO should reset UI for no sound
                return;
            }

            Iterator<AGEventHandler> it = mEventHandlerList.keySet().iterator();
            while (it.hasNext()) {
                AGEventHandler handler = it.next();
                handler.onExtraCallback(AGEventHandler.EVENT_TYPE_ON_SPEAKER_STATS, (Object) speakerInfos);
            }
        }

        /**
         * Occurs when a user leaves the channel.
         *
         * When the app calls the leaveChannel method, the SDK uses this callback to notify the app when the user leaves the channel.
         *
         * With this callback, the application retrieves the channel information, such as the call duration and statistics.
         *
         * @param stats Statistics of the call: RtcStats
         */
        @Override
        public void onLeaveChannel(RtcStats stats) {

        }

        /**
         * Reports the last mile network quality of the local user once every two seconds before the user joins the channel. Last mile refers to the connection between the local device and Agora's edge server. After the application calls the enableLastmileTest method, this callback reports once every two seconds the uplink and downlink last mile network conditions of the local user before the user joins the channel.
         * @param quality The last mile network quality based on the uplink and dowlink packet loss rate and jitter:
         *
         *     QUALITY_UNKNOWN(0): The quality is unknown.
         *     QUALITY_EXCELLENT(1): The quality is excellent.
         *     QUALITY_GOOD(2): The quality is quite good, but the bitrate may be slightly lower than excellent.
         *     QUALITY_POOR(3): Users can feel the communication slightly impaired.
         *     QUALITY_BAD(4): Users can communicate not very smoothly.
         *     QUALITY_VBAD(5): The quality is so bad that users can barely communicate.
         *     QUALITY_DOWN(6): The network is disconnected and users cannot communicate at all.
         *     QUALITY_DETECTING(8): The SDK is detecting the network quality.
         */
        @Override
        public void onLastmileQuality(int quality) {
            log.debug("onLastmileQuality " + quality);
        }

        /**
         * Reports an error during SDK runtime.
         *
         * In most cases, the SDK cannot fix the issue and resume running. The SDK requires the app to take action or informs the user about the issue.
         *
         * For example, the SDK reports an ERR_START_CALL error when failing to initialize a call. The app informs the user that the call initialization failed and invokes the leaveChannel method to leave the channel. For detailed error codes, see Error Codes.
         *
         * @param error Error Code
         */
        @Override
        public void onError(int error) {
            log.debug("onError " + error);

            Iterator<AGEventHandler> it = mEventHandlerList.keySet().iterator();
            while (it.hasNext()) {
                AGEventHandler handler = it.next();
                handler.onExtraCallback(AGEventHandler.EVENT_TYPE_ON_AGORA_MEDIA_ERROR, error, RtcEngine.getErrorDescription(error));
            }
        }

        /**
         * Reports the statistics of the audio stream from each remote user/host.
         * The SDK triggers this callback once every two seconds to report the audio quality of each remote user/host sending an audio stream. If a channel has multiple remote users/hosts sending audio streams, the SDK trggers this callback as many times.
         *
         * @param uid User ID of the speaker.
         * @param quality    Audio quality of the user:
         *
         *     QUALITY_UNKNOWN(0): The quality is unknown.
         *     QUALITY_EXCELLENT(1): The quality is excellent.
         *     QUALITY_GOOD(2): The quality is quite good, but the bitrate may be slightly lower than excellent.
         *     QUALITY_POOR(3): Users can feel the communication slightly impaired.
         *     QUALITY_BAD(4): Users can communicate not very smoothly.
         *     QUALITY_VBAD(5): The quality is so bad that users can barely communicate.
         *     QUALITY_DOWN(6): The network is disconnected and users cannot communicate at all.
         *     QUALITY_DETECTING(8): The SDK is detecting the network quality.
         *
         * @param delay Time delay (ms) of the audio packet from the sender to the receiver, including the time delay from audio sampling pre-processing, transmission, and the jitter buffer.
         * @param lost Packet loss rate (%) of the audio packet sent from the sender to the receiver.
         */
        @Override
        public void onAudioQuality(int uid, int quality, short delay, short lost) {
            Iterator<AGEventHandler> it = mEventHandlerList.keySet().iterator();
            while (it.hasNext()) {
                AGEventHandler handler = it.next();
                handler.onExtraCallback(AGEventHandler.EVENT_TYPE_ON_AUDIO_QUALITY, uid, quality, delay, lost);
            }
        }

        /**
         * Occurs when your connection is banned by the Agora Server.
         */
        @Override
        public void onConnectionLost() {
            log.debug("onConnectionLost");

            Iterator<AGEventHandler> it = mEventHandlerList.keySet().iterator();
            while (it.hasNext()) {
                AGEventHandler handler = it.next();
                handler.onExtraCallback(AGEventHandler.EVENT_TYPE_ON_APP_ERROR, ConstantApp.AppError.NO_NETWORK_CONNECTION);
            }
        }

        /**
         * Occurs when the connection between the SDK and the server is interrupted.
         * The SDK triggers this callback when it loses connection to the server for more than four seconds after the connection is established. After triggering this callback, the SDK tries to reconnect to the server. You can use this callback to implement pop-up reminders. This callback is different from onConnectionLost:
         *
         *     The SDK triggers the onConnectionInterrupted callback when the SDK loses connection with the server for more than four seconds after it joins the channel.
         *     The SDK triggers the onConnectionLost callback when it loses connection with the server for more than 10 seconds, regardless of whether it joins the channel or not.
         *
         * If the SDK fails to rejoin the channel 20 minutes after being disconnected from Agora's edge server, the SDK stops rejoining the channel.
         */
        @Override
        public void onConnectionInterrupted() {
            log.debug("onConnectionInterrupted");

            Iterator<AGEventHandler> it = mEventHandlerList.keySet().iterator();
            while (it.hasNext()) {
                AGEventHandler handler = it.next();
                handler.onExtraCallback(AGEventHandler.EVENT_TYPE_ON_APP_ERROR, ConstantApp.AppError.NO_NETWORK_CONNECTION);
            }
        }

        /**
         * Occurs when the local user joins a specified channel.
         * The channel name assignment is based on channelName specified in the joinChannel method.
         * If the uid is not specified when joinChannel is called, the server automatically assigns a uid.
         *
         * @param channel Channel name.
         * @param uid User ID.
         * @param elapsed Time elapsed (ms) from the user calling joinChannel until this callback is triggered.
         */
        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            log.debug("onJoinChannelSuccess " + channel + " " + (uid & 0xFFFFFFFFL) + " " + elapsed);

            mConfig.mUid = uid;

            Iterator<AGEventHandler> it = mEventHandlerList.keySet().iterator();
            while (it.hasNext()) {
                AGEventHandler handler = it.next();
                handler.onJoinChannelSuccess(channel, uid, elapsed);
            }
        }

        /**
         * Occurs when a user rejoins the channel after being disconnected due to network problems.
         *
         * When a user loses connection with the server because of network problems, the SDK automatically tries to reconnect and triggers this callback upon reconnection.
         *
         * @param channel Channel name.
         * @param uid User ID.
         * @param elapsed Time elapsed (ms) from starting to reconnect until this callback is triggered.
         */
        public void onRejoinChannelSuccess(String channel, int uid, int elapsed) {
            log.debug("onRejoinChannelSuccess " + channel + " " + (uid & 0xFFFFFFFFL) + " " + elapsed);
        }

        /**
         * Reports a warning during SDK runtime.
         *
         * In most cases, the app can ignore the warning reported by the SDK because the SDK can usually fix the issue and resume running.
         *
         * For instance, the SDK may report a WARN_LOOKUP_CHANNEL_TIMEOUT warning upon disconnection with the server and tries to reconnect. For detailed warning codes, see Warning Codes.
         *
         * @param warn Warning code
         */
        public void onWarning(int warn) {
            log.debug("onWarning " + warn);
        }

        /**
         * Occurs when the local audio playback route changes.
         * This callback returns that the audio route switched to an earpiece, speakerphone, headset, or Bluetooth device.
         * The definition of the routing is listed as follows:

         AUDIO_ROUTE_DEFAULT(-1): Default audio route.
         AUDIO_ROUTE_HEADSET(0): Headset.
         AUDIO_ROUTE_EARPIECE(1): Earpiece.
         AUDIO_ROUTE_HEADSETNOMIC(2): Headset with no microphone.
         AUDIO_ROUTE_SPEAKERPHONE(3): Speakerphone.
         AUDIO_ROUTE_LOUDSPEAKER(4): Loudspeaker.
         AUDIO_ROUTE_HEADSETBLUETOOTH(5): Bluetooth headset.
         */
        @Override
        public void onAudioRouteChanged(int routing) {
            log.debug("onAudioRouteChanged " + routing);

            Iterator<AGEventHandler> it = mEventHandlerList.keySet().iterator();
            while (it.hasNext()) {
                AGEventHandler handler = it.next();
                handler.onExtraCallback(AGEventHandler.EVENT_TYPE_ON_AUDIO_ROUTE_CHANGED, routing);
            }

        }
    };

}
