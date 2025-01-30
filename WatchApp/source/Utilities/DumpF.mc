import Toybox.System;
import Toybox.Lang;

(:background, :glance)
function dumpF(tag as Lang.String, loc as Lang.String) as Void {
    _3(tag, loc + ".f", System.getSystemStats().freeMemory);
}
