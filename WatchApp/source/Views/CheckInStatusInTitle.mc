using Toybox.Lang;
using Toybox.System;

function titleFromCheckInStatus(checkInStatus as CheckInStatus) as Lang.String {
    var title;
    switch (checkInStatus) {
        case CHECK_IN_IN_PROGRESS:
            title = "Syncing";
            break;
        case CHECK_IN_SUCCEEDED:
            title = "Idle";
            break;
        case CHECK_IN_FAILED:
            title = "Sync failed";
            break;
        case CHECK_IN_NONE:
            title = null;
            break;
        default: {
            title = null;
            System.error("unknownCheckInStatus: " + checkInStatus);
        }
    }
    return joinComponents([title, headsetStatusRep()], " ");
}