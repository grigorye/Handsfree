import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

(:noLowMemory)
function updateStatusMenu() as Void {
    var menu = statusMenu();
    if (menu != null) {
        var title = statusMenuTitle();
        menu.setTitle(title);
        workaroundNoRedrawForMenu2(menu);
    }
}

(:lowMemory)
function statusMenuTitle() as StringOrResource {
    return Rez.Strings.contacts;
}

(:noLowMemory)
function statusMenuTitle() as StringOrResource {
    var statsRep = statsRep();
    var nonNullStatsRep = statsRep != null ? statsRep : Rez.Strings.contacts;
    var connectionStatusRep = connectionStatusRep();
    return joinNonNullComponents(
        [
            nonNullStatsRep,
            connectionStatusRep
        ],
        " "
    );
}

(:noLowMemory)
function connectionStatusRep() as StringOrResource | Null {
    if (!System.getDeviceSettings().phoneConnected) {
        return Rez.Strings.connectionStatusDisconnected;
    }
    return headsetStatusRep();
}