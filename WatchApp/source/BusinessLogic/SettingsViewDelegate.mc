import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

(:noLowMemory)
module SettingsScreen {

class ViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Symbol;
        switch (id) {
            case :openAppOnIncomingCall: {
                AppSettings.toggle(Settings_openAppOnIncomingCallK);
                appConfigDidChange();
                break;
            }
            case :optimisticCallHandling: {
                AppSettings.toggle(Settings_optimisticCallHandlingK);
                break;
            }
            case :broadcastListening: {
                AppSettings.toggle(Settings_broadcastListeningK);
                var newValue = isBroadcastListeningEnabled();
                if (newValue) {
                    TemporalBroadcasting.stopTemporalSubjectsBroadcasting();
                } else {
                    TemporalBroadcasting.startTemporalSubjectsBroadcasting();
                }
                appConfigDidChange();
                break;
            }
            case :about: {
                VT.pushView(V_about, Views.newAboutView(), new AboutViewDelegate(), WatchUi.SLIDE_LEFT);
                break;
            }
            case :installCompanionApp: {
                Req.installCompanionApp();
                break;
            }
        }
    }

    function onBack() as Void {
        VT.popView(WatchUi.SLIDE_RIGHT);
    }
}

}
