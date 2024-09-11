using Toybox.System;
using Toybox.WatchUi;
using Toybox.Lang;

(:noLowMemory)
function crashMe() as Void {
    var deviceSettings = System.getDeviceSettings();
    var info = {
        "crashMe" => null,
        "fontScale" => deviceSettings has :fontScale ? deviceSettings.fontScale : null,
        "isEnhancedReadabilityModeEnabled" => deviceSettings has :isEnhancedReadabilityModeEnabled ? deviceSettings.isEnhancedReadabilityModeEnabled : null,
        "isGlanceModeEnabled" => System.DeviceSettings has :isGlanceModeEnabled ? deviceSettings.isGlanceModeEnabled : null,
        "partNumber" => deviceSettings.partNumber,
        "firmwareVersion" => deviceSettings.firmwareVersion,
        "monkeyVersion" => deviceSettings.monkeyVersion
    };

    var menu = new WatchUi.Menu2({});
    for (var i = 0; i < info.size(); ++i) {
        var key = info.keys()[i] as Lang.String;
        var value = Lang.format("$1$", [info[key]]);
        var item = new WatchUi.MenuItem(key, value, null, null);
        menu.addItem(item);
    }
    WatchUi.pushView(menu, new DebugMenuDelegate(), WatchUi.SLIDE_LEFT);
}

(:noLowMemory)
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