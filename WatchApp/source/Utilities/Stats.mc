using Toybox.System;
using Toybox.Lang;

(:background, :glance)
function systemStatsDumpRep() as Lang.Dictionary {
    var stats = System.getSystemStats();
    return {
        "freeMemory" => stats.freeMemory,
        "totalMemory" => stats.totalMemory,
        "usedMemory" => stats.usedMemory
    };
}