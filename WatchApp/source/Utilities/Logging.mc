using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

function dump(tag as Lang.String, output as Lang.Object or Null) as Void {
    if (newSession) {
        newSession = false;
        System.println("");
        System.println("-------------------");
    }

    var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    var timePrefix =
        (info.year as Lang.Number).format("%02d") + "/" +
        (info.month as Lang.Number).format("%02d") + "/" +
        info.day.format("%02d") + " " +
        info.hour.format("%02d") + ":" +
        info.min.format("%02d") + ":" +
        info.sec.format("%02d") + " ";
    System.println(timePrefix + tag + ": " + output);
}

var newSession as Lang.Boolean = true;
