import Toybox.WatchUi;

class SettingsView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "Settings" });
        addItem(incomingCallsMenuItem());
        addItem(optimisticCallHandlingMenuItem());
        addItem(new MenuItem("About", null, :about, null));
    }

    function incomingCallsMenuItem() as WatchUi.ToggleMenuItem {
        return new ToggleMenuItem(
            "Incoming Calls",
            {
                :enabled => "On",
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

    function update() as Void {
        (getItem(findItemById(:openAppOnIncomingCall)) as WatchUi.ToggleMenuItem).setEnabled(BackgroundSettings.isOpenAppOnIncomingCallEnabled());
        (getItem(findItemById(:optimisticCallHandling)) as WatchUi.ToggleMenuItem).setEnabled(AppSettings.isOptimisticCallHandlingEnabled());
        workaroundNoRedrawForMenu2(self);
    }
}

function newSettingsView() as SettingsView {
    var settingsView = new SettingsView();
    settingsView.update();
    return settingsView;
}