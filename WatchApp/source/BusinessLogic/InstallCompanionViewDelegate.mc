import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

class InstallCompanionViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Symbol;
        switch (id) {
            case :installCompanionApp: {
                installCompanionApp();
                break;
            }
        }
    }

    function onBack() as Void {
        popView(WatchUi.SLIDE_RIGHT);
        if (isCompanionUpToDate()) {
            routeToMainUI();
        } else {
            exitToSystemFromCommView();
        }
    }
}
