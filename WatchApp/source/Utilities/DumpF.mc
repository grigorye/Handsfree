import Toybox.System;
import Toybox.Lang;

(:background, :glance, :noMemDebug)
const memDebug = false;

(:background, :glance, :memDebug)
const memDebug = true;

(:background, :glance)
function dumpF(tag as Lang.String, loc as Lang.String) as Void {
    if (memDebug) { _3(tag, loc + ".f", System.getSystemStats().freeMemory); }
}
