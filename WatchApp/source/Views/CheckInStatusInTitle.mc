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
    var statsRep = statsRep();
    return joinComponents([statsRep != null ? statsRep : "Contacts", headsetStatusRep()], " ");
}
