using Toybox.WatchUi;

enum CheckInStatus {
    CHECK_IN_IN_PROGRESS = "Syncing",
    CHECK_IN_SUCCEEDED = "Idle",
    CHECK_IN_FAILED = "Failed"
}

var checkInStatusImp as CheckInStatus = CHECK_IN_IN_PROGRESS;

function getCheckInStatus() as CheckInStatus {
    return checkInStatusImp;
}

function setCheckInStatus(checkInStatus as CheckInStatus) as Void {
    dump("setCheckInStatus", checkInStatus);
    checkInStatusImp = checkInStatus;
    if (getCallState() instanceof Idle) {
        if (phonesViewImp == null) {
            dump("phonesViewImp", phonesViewImp);
            return;
        }
        getPhonesView().setTitleFromCheckInStatus(checkInStatus);
        getPhonesView().updateFromPhones(getPhones());
        WatchUi.requestUpdate();
    }
}
