import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

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
            case :optimisticCallHandling: {
                AppSettings.toggle("optimisticCallHandling");
                break;
            }
            case :broadcastListening: {
                AppSettings.toggle("broadcastListening");
                break;
            }
            case :about: {
                VT.pushView(V.about, Views.newAboutView(), new AboutViewDelegate(), WatchUi.SLIDE_LEFT);
                break;
            }
            case :installCompanionApp: {
                installCompanionApp();
                break;
            }
        }
    }

    function onBack() as Void {
        VT.popView(WatchUi.SLIDE_RIGHT);
    }
}
