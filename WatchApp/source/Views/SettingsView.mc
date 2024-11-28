import Toybox.WatchUi;

class SettingsView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "Settings" });
        addItem(incomingCallsMenuItem());
        addItem(new MenuItem("More: Connect IQ", null, :more, null));
        addItem(companionVersionItem());
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

    function companionVersionItem() as WatchUi.MenuItem {
        var companionInfo = CompanionInfoImp.getCompanionInfo();
        if (companionInfo == null) {
            return new MenuItem("Install Companion App", null, :installCompanionApp, null);
        } else {
            var versionCode = CompanionInfoImp.getCompanionVersionCode(companionInfo);
            var versionName = CompanionInfoImp.getCompanionVersionName(companionInfo);
            var sourceVersion = CompanionInfoImp.getCompanionSourceVersion(companionInfo);
            var title = "Companion App";
            var subtitle = versionName + " (" + versionCode + ") " + sourceVersion;
            return new MenuItem(title, subtitle, :installCompanionApp, null);
        }
    }

    function update() as Void {
        (getItem(findItemById(:openAppOnIncomingCall)) as WatchUi.ToggleMenuItem).setEnabled(BackgroundSettings.isOpenAppOnIncomingCallEnabled());
        workaroundNoRedrawForMenu2(self);
    }
}

function newSettingsView() as SettingsView {
    var settingsView = new SettingsView();
    settingsView.update();
    return settingsView;
}