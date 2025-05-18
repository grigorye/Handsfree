import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;

function crashMe() as Void {
    var deviceSettings = System.getDeviceSettings();
    var stats = System.getSystemStats();
    var backgroundStats = BackgroundSystemStats.getBackgroundSystemStats();
    var infos = [
        ["crashMe", null],
        ["turnOffBroadcasting", null],
        ["stats", statsRep()],
        ["readinessInfo", readinessInfoCompact()],
        ["freeMemory", [stats.freeMemory, backgroundStats["f"]]],
        ["totalMemory", [stats.totalMemory, backgroundStats["t"]]],
        ["usedMemory", [stats.usedMemory, backgroundStats["u"]]],
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
        if (item.getLabel().equals("turnOffBroadcasting")) {
            TemporalBroadcasting.stopTemporalSubjectsBroadcasting();
            WatchUi.showToast("Broadcasting Off", null);
        }
        if (item.getLabel().equals("stats")) {
            Storage.clearValues();
            WatchUi.showToast("Storage Erased", null);
        }
    }
}

(:noReadiness)
function readinessInfoCompact() as Lang.String {
    return "?";
}

(:readiness)
function readinessInfoCompact() as Lang.String {
    var readinessInfo = Storage.getValue(ReadinessInfo_valueKey) as ReadinessInfo | Null;
    if (readinessInfo == null) {
        return "null";
    }
    var r = "";
    var allVariants = [ReadinessField_essentials, ReadinessField_outgoingCalls, ReadinessField_recents, ReadinessField_incomingCalls, ReadinessField_starredContacts];
    for (var i = 0; i < allVariants.size(); ++i) {
        var variant = allVariants[i];
        r = r + variant + ":" + readinessInfo[variant];
        if (i < allVariants.size() - 1) {
            r = r + "|";
        }
    }
    return r;
}