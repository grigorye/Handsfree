using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:glance, :background)
function dump(tag as Lang.String, output as Lang.Object or Null) as Void {
    var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    if (newSession) {
        newSession = false;
        System.println("");
        var dateFormatted =
            (info.year as Lang.Number).format("%02d") + "/" +
            (info.month as Lang.Number).format("%02d") + "/" +
            info.day.format("%02d");

        //             "23:57:28 "
        System.println("-------- " + dateFormatted + " (" + sourceVersion() + ")");
    }

    var timePrefix =
        info.hour.format("%02d") + ":" +
        info.min.format("%02d") + ":" +
        info.sec.format("%02d") + " ";
    System.println(timePrefix + tag + ": " + output);
}

(:glance, :background)
var newSession as Lang.Boolean = true;
