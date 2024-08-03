using Toybox.WatchUi;

enum CheckInStatus {
    CHECK_IN_NONE = "none",
    CHECK_IN_IN_PROGRESS = "in-progress",
    CHECK_IN_SUCCEEDED = "succeeded",
    CHECK_IN_FAILED = "failed"
}

var checkInStatusImp as CheckInStatus = CHECK_IN_IN_PROGRESS;

function getCheckInStatus() as CheckInStatus {
    return checkInStatusImp;
}

function setCheckInStatus(checkInStatus as CheckInStatus) as Void {
    dump("setCheckInStatus", checkInStatus);
    checkInStatusImp = checkInStatus;
    if (getCallState() instanceof Idle) {
        updatePhonesView();
    }
}
