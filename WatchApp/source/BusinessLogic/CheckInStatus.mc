using Toybox.WatchUi;

const L_CHECK_IN_STATUS as LogComponent = "checkInStatus";

enum CheckInStatus {
    CHECK_IN_NONE = "none",
    CHECK_IN_IN_PROGRESS = "in-progress",
    CHECK_IN_SUCCEEDED = "succeeded",
    CHECK_IN_FAILED = "failed"
}

var checkInStatusImp as CheckInStatus = CHECK_IN_NONE;

function setCheckInStatus(checkInStatus as CheckInStatus) as Void {
    _3(L_CHECK_IN_STATUS, "set", checkInStatus);
    checkInStatusImp = checkInStatus;
    updateForCheckInStatus();
}
