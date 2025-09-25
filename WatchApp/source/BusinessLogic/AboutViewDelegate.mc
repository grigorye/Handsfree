import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

(:settings)
class AboutViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Symbol;
        switch (id) {
            case :more: {
                Req.openAppInConnectIQ();
                break;
            }
            case :installCompanionApp: {
                if (companionInfoEnabled) {
                    Req.installCompanionApp();
                }
                break;
            }
        }
    }

    function onBack() as Void {
        VT.popView(WatchUi.SLIDE_RIGHT);
    }
}
