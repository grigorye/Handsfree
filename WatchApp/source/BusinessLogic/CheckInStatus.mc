import Toybox.WatchUi;

(:noLowMemory)
const L_CHECK_IN_STATUS as LogComponent = "checkInStatus";

(:noLowMemory)
enum CheckInStatus {
    CHECK_IN_NONE = "none",
    CHECK_IN_IN_PROGRESS = "in-progress",
    CHECK_IN_SUCCEEDED = "succeeded",
    CHECK_IN_FAILED = "failed"
}

(:noLowMemory)
var checkInStatusImp as CheckInStatus = CHECK_IN_NONE;

(:noLowMemory)
function setCheckInStatus(checkInStatus as CheckInStatus) as Void {
    if (debug) { _3(L_CHECK_IN_STATUS, "set", checkInStatus); }
    checkInStatusImp = checkInStatus;
    updateForCheckInStatus();
}
