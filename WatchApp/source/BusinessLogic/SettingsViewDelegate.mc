using Toybox.WatchUi;
using Toybox.Lang;

class SettingsViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Symbol;
        switch (id) {
            case :openAppOnIncomingCall: {
                AppSettings.toggle("openAppOnIncomingCall");
                break;
            }
        }
    }

    function onBack() as Void {
        popView(WatchUi.SLIDE_RIGHT);
    }
}
