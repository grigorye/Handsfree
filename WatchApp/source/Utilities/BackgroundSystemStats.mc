import Toybox.System;
import Toybox.Application;
import Toybox.Lang;

(:background)
function saveBackgroundSystemStats() as Void {
    var stats = System.getSystemStats();
    var statsRep = {
        "f" => stats.freeMemory,
        "t" => stats.totalMemory,
        "u" => stats.usedMemory
    };
    Storage.setValue("backgroundSystemStats", statsRep as Application.PropertyValueType);
}

function getBackgroundSystemStats() as Lang.Dictionary<Lang.String, Lang.Number> {
    var savedStats = Storage.getValue("backgroundSystemStats") as Lang.Dictionary<Lang.String, Lang.Number> or Null;
    if (savedStats == null) {
        return {
            "f" => 0,
            "t" => 0,
            "u" => 0
        } as Lang.Dictionary<Lang.String, Lang.Number>;
    }
    return savedStats; 
}