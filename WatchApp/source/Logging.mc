using Toybox.System;
using Toybox.Lang;

function dump(tag as Lang.String, output as Lang.Object or Null) {
    var myTime = System.getClockTime();
    var timePrefix =
        myTime.hour.format("%02d") + ":" +
        myTime.min.format("%02d") + ":" +
        myTime.sec.format("%02d") + " ";
    System.println(timePrefix + tag + ": " + output);
}