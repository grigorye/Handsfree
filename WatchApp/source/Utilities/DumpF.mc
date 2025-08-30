import Toybox.System;
import Toybox.Lang;

(:background, :glance)
const memDebug = false;

(:background, :glance)
function dumpF(tag as Lang.String, loc as Lang.String) as Void {
    if (memDebug) { _3(tag, loc + ".f", System.getSystemStats().freeMemory); }
}
