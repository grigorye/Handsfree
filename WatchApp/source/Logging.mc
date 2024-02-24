using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

function dump(tag as Lang.String, output as Lang.Object or Null) {
    var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    var timePrefix =
        info.year.format("%02d") + "/" +
        info.month.format("%02d") + "/" +
        info.day.format("%02d") + " " +
        info.hour.format("%02d") + ":" +
        info.min.format("%02d") + ":" +
        info.sec.format("%02d") + " ";
    System.println(timePrefix + tag + ": " + output);
}