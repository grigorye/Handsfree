import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

class AboutViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Symbol;
        switch (id) {
            case :more: {
                openAppInConnectIQ();
                break;
            }
            case :installCompanionApp: {
                installCompanionApp();
                break;
            }
        }
    }

    function onBack() as Void {
        popView(WatchUi.SLIDE_RIGHT);
    }
}
