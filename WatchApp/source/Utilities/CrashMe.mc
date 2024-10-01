import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;

function crashMe() as Void {
    var deviceSettings = System.getDeviceSettings();
    var infos = [
        ["crashMe", null],
        ["fontScale", deviceSettings has :fontScale ? deviceSettings.fontScale : null],
        ["isEnhancedReadabilityModeEnabled", deviceSettings has :isEnhancedReadabilityModeEnabled ? deviceSettings.isEnhancedReadabilityModeEnabled : null],
        ["isGlanceModeEnabled", System.DeviceSettings has :isGlanceModeEnabled ? deviceSettings.isGlanceModeEnabled : null],
        ["partNumber", deviceSettings.partNumber],
        ["firmwareVersion", deviceSettings.firmwareVersion],
        ["monkeyVersion", deviceSettings.monkeyVersion]
    ];

    var menu = new WatchUi.Menu2({ :title => "Debug" });
    for (var i = 0; i < infos.size(); ++i) {
        var info = infos[i];
        var key = info[0] as Lang.String;
        var value = Lang.format("$1$", [info[1]]);
        var item = new WatchUi.MenuItem(key, value, null, null);
        menu.addItem(item);
    }
    WatchUi.pushView(menu, new DebugMenuDelegate(), WatchUi.SLIDE_LEFT);
}

class DebugMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        if (item.getLabel().equals("crashMe")) {
            System.error("Crashing!");
        }
    }
}