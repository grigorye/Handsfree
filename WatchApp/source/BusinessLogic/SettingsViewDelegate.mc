import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

(:noSettings)
const hasSettings = false;
(:settings)
const hasSettings = true;

(:settings)
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
            case :showPhoneNumbers: {
                AppSettings.toggle(Settings_showPhoneNumbersK);
                var phonesView = VT.viewWithTag(V_phones) as PhonesScreen.View or Null;
                if (phonesView != null) {
                    phonesView.updateForSettings();
                }
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
