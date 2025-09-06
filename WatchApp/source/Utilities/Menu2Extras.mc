import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

function deleteNMenuItems(menu as WatchUi.Menu2, index as Lang.Number, itemCount as Lang.Number) as Void {
    for (var i = index; i < index + itemCount; i++) {
        var existed = menu.deleteItem(index);
        if (existed == null) {
            if (testDebug) {
                System.error("Failed to delete menu item at index " + index);
            } else {
                System.error("");
            }
        }
    }
}