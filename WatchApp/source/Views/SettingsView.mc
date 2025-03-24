import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;

(:settings)
module SettingsScreen {

class View extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "Settings" });
        addItem(incomingCallsMenuItem());
        addItem(optimisticCallHandlingMenuItem());
        addItem(broadcastListeningMenuItem());
        addItem(new MenuItem("About", null, :about, null));
    }

    function incomingCallsMenuItem() as WatchUi.ToggleMenuItem {
        return new ToggleMenuItem(
            "Ringing",
            {
                :enabled => incomingCallsEnabledMenuItemTitle(),
                :disabled => "Off"
            },
            :openAppOnIncomingCall,
            BackgroundSettings.isOpenAppOnIncomingCallEnabled(),
            null
        );
    }

    function optimisticCallHandlingMenuItem() as WatchUi.ToggleMenuItem {
        return new ToggleMenuItem(
            "Faster Calls",
            {
                :enabled => "On",
                :disabled => "Off"
            },
            :optimisticCallHandling,
            AppSettings.isOptimisticCallHandlingEnabled(),
            null
        );
    }

    function broadcastListeningMenuItem() as WatchUi.ToggleMenuItem {
        return new ToggleMenuItem(
            "Eager Sync",
            {
                :enabled => "On",
                :disabled => "Off"
            },
            :broadcastListening,
            isBroadcastListeningEnabled(),
            null
        );
    }

    function update() as Void {
        (getItem(findItemById(:openAppOnIncomingCall)) as WatchUi.ToggleMenuItem).setEnabled(BackgroundSettings.isOpenAppOnIncomingCallEnabled());
        (getItem(findItemById(:optimisticCallHandling)) as WatchUi.ToggleMenuItem).setEnabled(AppSettings.isOptimisticCallHandlingEnabled());
        (getItem(findItemById(:broadcastListening)) as WatchUi.ToggleMenuItem).setEnabled(isBroadcastListeningEnabled());
        workaroundNoRedrawForMenu2(self);
    }
}

(:noReadiness)
function incomingCallsEnabledMenuItemTitle() as Lang.String {
    return BackgroundSettings.isIncomingOpenAppViaCompanionEnabled ? "Vibration/Alert" : "Alert";
}

(:readiness)
function incomingCallsEnabledMenuItemTitle() as Lang.String {
    var readiness = ReadinessInfoManip.readiness(ReadinessField_incomingCalls);
    if (!readiness.equals(ReadinessValue_ready)) {
        return "On (Not ready)";
    } else {
        return BackgroundSettings.isIncomingOpenAppViaCompanionEnabled ? "Vibration/Alert" : "Alert";
    }
}

}

(:settings)
function newSettingsView() as SettingsScreen.View {
    var settingsView = new SettingsScreen.View();
    settingsView.update();
    return settingsView;
}
