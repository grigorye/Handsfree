using Toybox.Lang;
using Toybox.Timer;

(:noLowMemory)
const L_CHECK_IN as LogComponent = "checkIn";

(:noLowMemory)
function getCheckIn() as CheckIn {
    if (checkInImp == null) {
        checkInImp = new CheckIn();
    }
    return checkInImp as CheckIn;
}

(:noLowMemory)
var checkInImp as CheckIn or Null;

(:noLowMemory)
class CheckIn {
    private var checkInAttemptsRemaining as Lang.Number;
    private var secondsToCheckIn as Lang.Number;
    private var checkInTimer as Timer.Timer or Null = null;

    function initialize() {
        checkInAttemptsRemaining = AppSettings.initialAttemptsToCheckin;
        secondsToCheckIn = AppSettings.initialSecondsToCheckin;
    }

    function launch() as Void {
        _3(L_CHECK_IN, "launch.originalCheckInStatus", checkInStatusImp);
        setCheckInStatus(CHECK_IN_IN_PROGRESS);
        attemptToCheckIn();
    }

    function cancel() as Void {
        _2(L_CHECK_IN, "cancel");
        if (checkInTimer != null) {
            (checkInTimer as Timer.Timer).stop();
            checkInTimer = null;
        }
    }

    function attemptToCheckIn() as Void {
        _3(L_CHECK_IN, "checkInAttemptsRemaining", checkInAttemptsRemaining);
        _3(L_CHECK_IN, "preCheckInCallStateIsOwnedByUs", callStateIsOwnedByUs);
        callStateIsOwnedByUs = false;
        _3(L_CHECK_IN, "postCheckInCallStateIsOwnedByUs", callStateIsOwnedByUs);
        if (checkInAttemptsRemaining == 0) {
            setCheckInStatus(CHECK_IN_FAILED);
            _3(L_CHECK_IN, "timedOut", true);
            return;
        }
        _3(L_CHECK_IN, "secondsToCheckIn", secondsToCheckIn);
        if (checkInTimer != null) {
            checkInTimer.stop();
        } else {
            checkInTimer = new Timer.Timer();
        }
        (checkInTimer as Timer.Timer).start(method(:attemptToCheckIn), 1000 * secondsToCheckIn, false);
        checkInAttemptsRemaining -= 1;
        secondsToCheckIn *= 2;
        if (AppSettings.isSyncingCallStateOnCheckinEnabled) {
            requestSync();
        } else {
            requestPhones();
        }
    }

    function remoteResponded() as Void {
        _2(L_CHECK_IN, "remoteResponded");
        if (checkInTimer != null) {
            checkInTimer.stop();
            setCheckInStatus(CHECK_IN_SUCCEEDED);
            checkInTimer = null;
        }
    }
}