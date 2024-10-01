import Toybox.WatchUi;
import Toybox.Lang;

function updateRecentsMenuItem() as Void {
    var menu = recentsItemMenu();
    if (menu != null) {
        updateRecentsItemInMenu(menu);
        workaroundNoRedrawForMenu2(menu);
    }
}

function updateRecentsItemInMenu(menu as WatchUi.Menu2) as Void {
    var recentsItemIndex = menu.findItemById(:recents);
    if (recentsItemIndex != null) {
        var recentsItem = menu.getItem(recentsItemIndex);
        if (recentsItem != null) {
            recentsItem.setLabel(menuItemLabelFromRecents());
        }
    }
}

function menuItemLabelFromRecents() as Lang.String {
    return joinComponents([extraMenuItemPrefix + "Recents", missedCallsRep()], " ");
}
