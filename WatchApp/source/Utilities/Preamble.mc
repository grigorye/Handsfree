import Toybox.System;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:glance, :background)
function _preamble() as Void {
    var now = Time.now();
    var info = Gregorian.info(now, Time.FORMAT_SHORT);
    System.println("");
    var timeFormatted = info.hour.format("%02d") + ":" + info.min.format("%02d") + ":" + info.sec.format("%02d");
    var dateFormatted =
        info.year.format("%02d") + "/" +
        (info.month as Lang.Number).format("%02d") + "/" +
        info.day.format("%02d");
    var stats = System.getSystemStats();
    var statsRep = {
        "f" => stats.freeMemory,
        "t" => stats.totalMemory,
        "u" => stats.usedMemory
    };
    //             "23:57:28 "
    System.println("-------- " + dateFormatted + " " + timeFormatted + " (" + sourceVersion + ") (" + targetUiType + ") (" + statsRep + ")");
}
