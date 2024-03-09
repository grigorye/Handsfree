using Toybox.Application;
using Toybox.Communications;
using Toybox.Lang;
using Toybox.Timer;

var syncImp as Sync or Null;

function getSync() as Sync {
    if (syncImp == null) {
        syncImp = new Sync();
    }
    return syncImp as Sync;
}

class Sync {
    var readyToSync as Lang.Boolean = false;
    var remoteResponded as Lang.Boolean = false;
    var checkInAttemptsRemaining as Lang.Number;
    var secondsToCheckIn as Lang.Number;
    var checkInTimer as Timer.Timer or Null = null;

    function initialize() {
        dump("registerForPhoneAppMessages", true);
        Communications.registerForPhoneAppMessages(method(:onPhone));
        readyToSync = true;
        checkInAttemptsRemaining = Application.Properties.getValue("syncAttempts") as Lang.Number;
        secondsToCheckIn = Application.Properties.getValue("secondsToCheckIn") as Lang.Number;
    }

    function checkIn() as Void {
        dump("preCheckInCallStateIsOwnedByUs", callStateIsOwnedByUs);
        dump("remoteResponded", remoteResponded);
        if (remoteResponded) {
            setCheckInStatus(CHECK_IN_SUCCEEDED);
            return;
        }
        callStateIsOwnedByUs = false;
        dump("postCheckInCallStateIsOwnedByUs", callStateIsOwnedByUs);
        dump("checkInAttemptsRemaining", checkInAttemptsRemaining);
        if (checkInAttemptsRemaining == 0) {
            setCheckInStatus(CHECK_IN_FAILED);
            dump("checkInTimedOut", true);
            return;
        }
        dump("secondsToCheckIn", secondsToCheckIn);
        var timer = new Timer.Timer();
        checkInTimer = timer;
        timer.start(method(:checkIn), 1000 * secondsToCheckIn, false);
        checkInAttemptsRemaining -= 1;
        secondsToCheckIn *= 2;
        requestSync();
    }

    function onPhone(msg as Communications.Message) as Void {
        if (!readyToSync) {
            dump("flushedMsg", msg);
            return;
        }
        if (!remoteResponded) {
            remoteResponded = true;
            (checkInTimer as Timer.Timer).stop();
            checkIn();
            checkInTimer = null;
        }
        handleRemoteMessage(msg);
    }
}