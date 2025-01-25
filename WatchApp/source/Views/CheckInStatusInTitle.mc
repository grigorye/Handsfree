import Toybox.Lang;
import Toybox.System;

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
function statusMenuTitle() as Lang.String {
    return "Contacts";
}

(:noLowMemory)
function statusMenuTitle() as Lang.String {
    var statsRep = statsRep();
    return joinComponents(
        [
            statsRep != null ? statsRep : "Contacts",
            connectionStatusRep()
        ],
        " "
    );
}

(:noLowMemory)
function connectionStatusRep() as Lang.String or Null {
    if (!System.getDeviceSettings().phoneConnected) {
        return "@";
    }
    return headsetStatusRep();
}