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

(:noLowMemory)
function statusMenuTitle() as Lang.String {
    return joinComponents([joinComponents([headsetStatusRep(), statsRep()], "")], " ");
}
