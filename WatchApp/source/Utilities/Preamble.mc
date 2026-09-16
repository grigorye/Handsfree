import Toybox.System;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:glance, :background)
function _preamble() as Void {
    if (!(memDebug || testDebug)) {
        return;
    }
    var now = Time.now();
    var info = Gregorian.info(now, Time.FORMAT_SHORT);
    System.println("");
    var timeFormatted = Lang.format("$1$:$2$:$3$", [info.hour.format("%02d"), info.min.format("%02d"), info.sec.format("%02d")]);
    var dateFormatted = Lang.format("$1$/$2$/$3$", [info.year.format("%02d"), (info.month as Lang.Number).format("%02d"), info.day.format("%02d")]);
    var stats = System.getSystemStats();
    var statsRep = {
        "f" => stats.freeMemory,
        "t" => stats.totalMemory,
        "u" => stats.usedMemory
    };
    var featuresRep = targetUiType + "-"
        + (lowMemory ? "L" : "l")
        + (lowMemoryManifest ? "R" : "r")
        + (testDebug ? "T" : "t")
        + (memDebug ? "M" : "m")
        + (errorDebug ? "E" : "e")
        + (foregroundSubjectsEnabled ? "F" : "f");
    
    var message = Lang.format(
        "-------- $1$ $2$ ($3$) ($4$) ($5$)",
        [dateFormatted, timeFormatted, sourceVersion, featuresRep, statsRep]
    );
    System.println(message);
}
