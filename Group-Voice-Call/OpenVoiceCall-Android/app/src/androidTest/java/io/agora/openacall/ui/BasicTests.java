package io.agora.openacall.ui;

import android.test.ActivityInstrumentationTestCase2;

import com.robotium.solo.Condition;
import com.robotium.solo.Solo;

import io.agora.openacall.BuildConfig;
import io.agora.openacall.R;

public class BasicTests extends ActivityInstrumentationTestCase2<MainActivity> {

    private Solo solo;

    public BasicTests() {
        super(MainActivity.class);
    }

    @Override
    public void setUp() throws Exception {
        solo = new Solo(getInstrumentation(), getActivity());
    }

    @Override
    public void tearDown() throws Exception {
        solo.finishOpenedActivities();
    }

    public String getString(int resId) {
        return solo.getString(resId);
    }

    public void testJoinChannel() throws Exception {
        String AUTO_TEST_CHANNEL_NAME = "for_auto_test_" + BuildConfig.VERSION_NAME + BuildConfig.VERSION_CODE;

        solo.unlockScreen();

        solo.assertCurrentActivity("Expected MainActivity activity", "MainActivity");
        solo.clearEditText(0);
        solo.enterText(0, AUTO_TEST_CHANNEL_NAME);
        solo.waitForText(AUTO_TEST_CHANNEL_NAME, 1, 2000L);

        solo.clickOnView(solo.getView(R.id.button_join));

        String targetActivity = ChatActivity.class.getSimpleName();

        solo.waitForLogMessage("onJoinChannelSuccess " + AUTO_TEST_CHANNEL_NAME, JOIN_CHANNEL_SUCCESS_THRESHOLD + 1000);

        solo.assertCurrentActivity("Expected " + targetActivity + " activity", targetActivity);

        long firstRemoteAudioTs = System.currentTimeMillis();
        solo.waitForLogMessage("volume: ", FIRST_REMOTE_AUDIO_RECEIVED_THRESHOLD + 500);

        assertTrue("first remote audio frame not received", System.currentTimeMillis() - firstRemoteAudioTs <= FIRST_REMOTE_AUDIO_RECEIVED_THRESHOLD);

        solo.waitForCondition(new Condition() { // stay at the channel for some time
            @Override
            public boolean isSatisfied() {
                return false;
            }
        }, FIRST_REMOTE_AUDIO_RECEIVED_THRESHOLD);
    }

    private static final int FIRST_REMOTE_AUDIO_RECEIVED_THRESHOLD = 50 * 1000;
    private static final int JOIN_CHANNEL_SUCCESS_THRESHOLD = 5000;
}
