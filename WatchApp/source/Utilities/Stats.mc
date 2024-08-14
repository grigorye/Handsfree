using Toybox.System;
using Toybox.Lang;

(:background, :glance)
function systemStatsDumpRep() as Lang.Dictionary {
    var stats = System.getSystemStats();
    return {
        "f" => stats.freeMemory,
        "t" => stats.totalMemory,
        "u" => stats.usedMemory
    };
}