import Toybox.WatchUi;

class SettingsView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "Settings" });
        addItem(new ToggleMenuItem("Incoming Calls", null, :openAppOnIncomingCall, false, null));
        if (Application.AppBase has :openAppSettingsEditor) {
            addItem(new MenuItem("More: Connect IQ", null, :more, null));
        }
    }

    function update() as Void {
        (getItem(findItemById(:openAppOnIncomingCall)) as WatchUi.ToggleMenuItem).setEnabled(BackgroundSettings.isOpenAppOnIncomingCallEnabled);
        workaroundNoRedrawForMenu2(self);
    }
}

function newSettingsView() as SettingsView {
    var settingsView = new SettingsView();
    settingsView.update();
    return settingsView;
}