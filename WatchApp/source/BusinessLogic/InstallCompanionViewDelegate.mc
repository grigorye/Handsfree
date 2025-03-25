import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

(:companion)
class InstallCompanionViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Symbol;
        switch (id) {
            case :installCompanionApp: {
                Req.installCompanionApp();
                break;
            }
        }
    }

    function onBack() as Void {
        VT.popView(WatchUi.SLIDE_RIGHT);
        if (companionStatus() == CompanionStatus_upToDate) {
            routeToMainUI();
        } else {
            exitToSystemFromCommView();
        }
    }
}
