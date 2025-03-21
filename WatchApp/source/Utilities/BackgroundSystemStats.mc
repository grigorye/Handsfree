import Toybox.System;
import Toybox.Application;
import Toybox.Lang;

module BackgroundSystemStats {
    (:background, :lowMemory)
    function saveBackgroundSystemStats() as Void {}
    (:lowMemory)
    function getBackgroundSystemStats() as Lang.Dictionary { return {}; }
}

(:noLowMemory)
module BackgroundSystemStats {

(:background)
function canSaveInBackground() as Lang.Boolean {
    var monkeyVersion = System.getDeviceSettings().monkeyVersion;
    return monkeyVersion[0] > 3 or (monkeyVersion[0] == 3 and monkeyVersion[1] >= 2);
}

(:background)
const Storage_backgroundSystemStats = "T" + valueKeySuffix;

(:background)
function saveBackgroundSystemStats() as Void {
    if (!canSaveInBackground()) {
        if (minDebug) { _3(L_APP_EXTRA, "canSaveInBackground", false); }
        return;
    }
    var stats = System.getSystemStats();
    var statsRep = {
        "f" => stats.freeMemory,
        "t" => stats.totalMemory,
        "u" => stats.usedMemory
    };
    Storage.setValue(Storage_backgroundSystemStats, statsRep as Application.PropertyValueType);
}

function getBackgroundSystemStats() as Lang.Dictionary<Lang.String, Lang.Number> {
    var savedStats = Storage.getValue(Storage_backgroundSystemStats) as Lang.Dictionary<Lang.String, Lang.Number> or Null;
    if (savedStats == null) {
        return {
            "f" => 0,
            "t" => 0,
            "u" => 0
        } as Lang.Dictionary<Lang.String, Lang.Number>;
    }
    return savedStats; 
}

}
