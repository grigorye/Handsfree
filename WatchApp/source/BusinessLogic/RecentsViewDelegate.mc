import Toybox.WatchUi;
import Toybox.Lang;

class RecentsViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Number or Recent;
        if (!lowMemory) {
            if (id.equals(noRecentsMenuItemId)) {
                requestSync();
                return;
            }
        }
        var selectedRecent = id as Recent;
        scheduleCall(selectedRecent);
    }

    function onBack() {
        popView(SLIDE_RIGHT);
    }
}
