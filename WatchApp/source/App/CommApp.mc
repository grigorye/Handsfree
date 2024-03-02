using Toybox.Application;
using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Timer;

class CommExample extends Application.AppBase {

    var isSupportedPlatform as Lang.Boolean = getIsSupportedPlatform();
    var readyToSync as Lang.Boolean = false;
    var remoteResponded as Lang.Boolean = false;
    var checkInAttemptsRemaining as Lang.Number = 3;
    var secondsToCheckIn as Lang.Number = 1;

    function initialize() {
        dump("initialize", true);
        Application.AppBase.initialize();
        if (!isSupportedPlatform) {
            return;
        }
        dump("registerForPhoneAppMessages", true);
        Communications.registerForPhoneAppMessages(method(:onPhone));
        readyToSync = true;
    }

    function onStart(state) {
        dump("onStart", state);
        Application.AppBase.onStart(state);
        checkIn();
    }

    function checkIn() as Void {
        dump("remoteResponded", remoteResponded);
        if (remoteResponded) {
            setCheckInStatus(CHECK_IN_SUCCEEDED);
            return;
        }
        dump("checkInAttemptsRemaining", checkInAttemptsRemaining);
        if (checkInAttemptsRemaining == 0) {
            setCheckInStatus(CHECK_IN_FAILED);
            dump("checkInTimedOut", true);
            return;
        }
        dump("secondsToCheckIn", secondsToCheckIn);
        var timer = new Timer.Timer();
        timer.start(method(:checkIn), 1000 * secondsToCheckIn, false);
        checkInAttemptsRemaining -= 1;
        secondsToCheckIn *= 2;
        requestSync();
    }

    function onStop(state) {
        dump("onStop", state);
        Application.AppBase.onStop(state);
    }

    function getInitialView() {
        dump("getInitialView", true);
        if (isSupportedPlatform) {
            return [new CommView()];
        } else {
            return [new WatchUi.ProgressBar("No support", 0.0)];
        }
    }

    function onPhone(msg as Communications.Message) as Void {
        if (!readyToSync) {
            dump("flushedMsg", msg);
            return;
        }
        remoteResponded = true;
        handleRemoteMessage(msg);
    }
}

function getIsSupportedPlatform() as Lang.Boolean {
    var hasRegisterForAppMessages = Communications has :registerForPhoneAppMessages;
    dump("hasRegisterForAppMessages", hasRegisterForAppMessages);
    return hasRegisterForAppMessages;
}
