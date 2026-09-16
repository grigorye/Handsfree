import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;

function crashMe() as Void {
    var deviceSettings = System.getDeviceSettings();
    var stats = System.getSystemStats();
    var backgroundStats = BackgroundSystemStats.getBackgroundSystemStats();
    var infos = [
        [Rez.Strings.debugKeyVersion, sourceVersion + (testDebug ? "-B" : "")],
        [Rez.Strings.debugKeyCrashMe, null],
        [Rez.Strings.debugKeyTurnOffBroadcasting, null],
        [Rez.Strings.debugKeyStats, statsRep()],
        [Rez.Strings.debugKeyReadinessInfo, readinessInfoCompact()],
        [Rez.Strings.debugKeySubjectsConfirmed, Storage.getValue(Storage_subjectsConfirmed) as Lang.String | Null],
        [Rez.Strings.debugKeyFreeMemory, [stats.freeMemory, backgroundStats["f"]]],
        [Rez.Strings.debugKeyTotalMemory, [stats.totalMemory, backgroundStats["t"]]],
        [Rez.Strings.debugKeyUsedMemory, [stats.usedMemory, backgroundStats["u"]]],
        [Rez.Strings.debugKeyFontScale, deviceSettings has :fontScale ? deviceSettings.fontScale : null],
        [Rez.Strings.debugKeyEnhancedReadability, deviceSettings has :isEnhancedReadabilityModeEnabled ? deviceSettings.isEnhancedReadabilityModeEnabled : null],
        [Rez.Strings.debugKeyGlanceMode, System.DeviceSettings has :isGlanceModeEnabled ? deviceSettings.isGlanceModeEnabled : null],
        [Rez.Strings.debugKeyPartNumber, deviceSettings.partNumber],
        [Rez.Strings.debugKeyFirmwareVersion, deviceSettings.firmwareVersion],
        [Rez.Strings.debugKeyMonkeyVersion, deviceSettings.monkeyVersion]
    ];

    var menu = new WatchUi.Menu2({ :title => Rez.Strings.menuDebug });
    for (var i = 0; i < infos.size(); ++i) {
        var info = infos[i] as Lang.Array;
        var key = info[0] as StringOrResource;
        var value = Lang.format("$1$", [info[1]]);
        var item = new WatchUi.MenuItem(key, value, key, null);
        menu.addItem(item);
    }
    WatchUi.pushView(menu, new DebugMenuDelegate(), WatchUi.SLIDE_LEFT);
}

class DebugMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        if (item.getId() == Rez.Strings.debugKeyCrashMe) {
            System.error("Crashing!");
        }
        if (item.getId() == Rez.Strings.debugKeyTurnOffBroadcasting) {
            TemporalBroadcasting.stopTemporalSubjectsBroadcasting();
            WatchUi.showToast(Rez.Strings.toastBroadcastingOff, null);
        }
        if (item.getId() == Rez.Strings.debugKeyStats) {
            Storage.clearValues();
            WatchUi.showToast(Rez.Strings.toastStorageErased, null);
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
        r += Lang.format("$1$:$2$", [variant, readinessInfo[variant]]);
        if (i < allVariants.size() - 1) {
            r += "|";
        }
    }
    return r;
}