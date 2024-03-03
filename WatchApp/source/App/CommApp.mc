using Toybox.Application;
using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Timer;

class CommExample extends Application.AppBase {

    var readyToSync as Lang.Boolean = false;
    var remoteResponded as Lang.Boolean = false;
    var checkInAttemptsRemaining as Lang.Number = 3;
    var secondsToCheckIn as Lang.Number = 1;

    function initialize() {
        dump("initialize", true);
        dump("deviceSettings", deviceSettingsDumpRep(System.getDeviceSettings()));
        Application.AppBase.initialize();
        phonesImp = loadPhones();
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
        return [new CommView()] as Lang.Array<WatchUi.Views or WatchUi.InputDelegates> or Null;
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

function deviceSettingsDumpRep(deviceSettings as System.DeviceSettings) as Lang.String {
    return ""
        + Lang.format("monkey: $1$.$2$.$3$", deviceSettings.monkeyVersion) 
        + ", "
        + Lang.format("firmware: $1$", deviceSettings.firmwareVersion)
        + ", "
        + Lang.format("part: $1$", [deviceSettings.partNumber]);
}
