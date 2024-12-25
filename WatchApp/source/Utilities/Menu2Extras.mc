import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

function deleteNMenuItems(menu as WatchUi.Menu2, itemCount as Lang.Number) as Void {
    for (var i = 0; i < itemCount; i++) {
        var existed = menu.deleteItem(0);
        if (existed == null) {
            System.error("Failed to delete menu item at index " + i);
        }
    }
}