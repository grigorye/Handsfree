import Toybox.WatchUi;

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
            "Incoming Calls",
            {
                :enabled => BackgroundSettings.isIncomingOpenAppViaCompanionEnabled ? "Vibration/Alert" : "Alert",
                :disabled => "Silent"
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
            "Background Sync",
            {
                :enabled => "On",
                :disabled => "Off"
            },
            :broadcastListening,
            BackgroundSettings.isBroadcastListeningEnabled(),
            null
        );
    }

    function update() as Void {
        (getItem(findItemById(:openAppOnIncomingCall)) as WatchUi.ToggleMenuItem).setEnabled(BackgroundSettings.isOpenAppOnIncomingCallEnabled());
        (getItem(findItemById(:optimisticCallHandling)) as WatchUi.ToggleMenuItem).setEnabled(AppSettings.isOptimisticCallHandlingEnabled());
        (getItem(findItemById(:broadcastListening)) as WatchUi.ToggleMenuItem).setEnabled(BackgroundSettings.isBroadcastListeningEnabled());
        workaroundNoRedrawForMenu2(self);
    }
}

}

function newSettingsView() as SettingsScreen.View {
    var settingsView = new SettingsScreen.View();
    settingsView.update();
    return settingsView;
}
