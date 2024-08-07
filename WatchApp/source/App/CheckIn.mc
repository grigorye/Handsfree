using Toybox.Lang;
using Toybox.Timer;

function getCheckIn() as CheckIn {
    if (checkInImp == null) {
        checkInImp = new CheckIn();
    }
    return checkInImp as CheckIn;
}

function getCheckInImp() as CheckIn or Null {
    return checkInImp;
}

function setCheckInImp(imp as CheckIn or Null) as Void {
    checkInImp = imp;
}

(:glance)
var checkInImp as CheckIn or Null;

class CheckIn {
    var checkInAttemptsRemaining as Lang.Number;
    var secondsToCheckIn as Lang.Number;
    var checkInTimer as Timer.Timer or Null = null;

    function initialize() {
        checkInAttemptsRemaining = initialAttemptsToCheckin();
        secondsToCheckIn = initialSecondsToCheckin();
    }

    function launch() as Void {
        dump("checkIn.launch.originalCheckInStatus", getCheckInStatus());
        setCheckInStatus(CHECK_IN_IN_PROGRESS);
        attemptToCheckIn();
    }

    function cancel() as Void {
        dump("checkIn.cancel", true);
        if (checkInTimer != null) {
            (checkInTimer as Timer.Timer).stop();
            checkInTimer = null;
        }
    }

    function attemptToCheckIn() as Void {
        dump("checkIn.attemptToCheckIn.remaining", checkInAttemptsRemaining);
        dump("preCheckInCallStateIsOwnedByUs", callStateIsOwnedByUs);
        callStateIsOwnedByUs = false;
        dump("postCheckInCallStateIsOwnedByUs", callStateIsOwnedByUs);
        if (checkInAttemptsRemaining == 0) {
            setCheckInStatus(CHECK_IN_FAILED);
            dump("checkInTimedOut", true);
            return;
        }
        dump("secondsToCheckIn", secondsToCheckIn);
        if (checkInTimer != null) {
            checkInTimer.stop();
        } else {
            checkInTimer = new Timer.Timer();
        }
        (checkInTimer as Timer.Timer).start(method(:attemptToCheckIn), 1000 * secondsToCheckIn, false);
        checkInAttemptsRemaining -= 1;
        secondsToCheckIn *= 2;
        if (isSyncingCallStateOnCheckinEnabled()) {
            requestSync();
        } else {
            requestPhones();
        }
    }

    function remoteResponded() as Void {
        dump("remoteResponded", true);
        if (checkInTimer != null) {
            checkInTimer.stop();
            setCheckInStatus(CHECK_IN_SUCCEEDED);
            checkInTimer = null;
        }
    }
}