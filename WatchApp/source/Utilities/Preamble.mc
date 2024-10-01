import Toybox.System;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:glance, :background)
function _preamble() as Void {
    var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    System.println("");
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
    System.println("-------- " + dateFormatted + " (" + sourceVersion + ") (" + targetUiType + ") (" + statsRep + ")");
}
