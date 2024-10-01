import Toybox.Lang;
import Toybox.System;

function updateStatusMenu() as Void {
    var menu = statusMenu();
    if (menu != null) {
        var title = titleFromCheckInStatus(checkInStatusImp);
        menu.setTitle(title);
        workaroundNoRedrawForMenu2(menu);
    }
}

(:noLowMemory)
function titleFromCheckInStatus(checkInStatus as CheckInStatus) as Lang.String {
    var title;
    switch (checkInStatus) {
        case CHECK_IN_IN_PROGRESS:
            title = "Syncing";
            break;
        case CHECK_IN_SUCCEEDED: {
            title = "Synced";
            break;
        }
        case CHECK_IN_FAILED:
            title = "Sync failed";
            break;
        case CHECK_IN_NONE:
            title = "Idle";
            break;
        default: {
            title = null;
            System.error("unknownCheckInStatus: " + checkInStatus);
        }
    }
    return joinComponents([title, joinComponents([headsetStatusRep(), statsRep()], "")], " ");
}
