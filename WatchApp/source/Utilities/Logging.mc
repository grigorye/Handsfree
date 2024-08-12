using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:glance, :background)
const noArg as Lang.Symbol = :noArg;

typedef LogComponent as Lang.String;

(:glance, :background)
function _2(component as LogComponent, tag as Lang.String) as Void {
    _3(component, tag, :noArg);
}

(:glance, :background)
function _3(component as LogComponent, tag as Lang.String, value as Lang.Object or Null) as Void {
    if (!isLogAllEnforced() && !isLogComponentEnforced(component)) {
        return;
    }
    var qualifiedTag = component + "." + tag;
    dumpImp(qualifiedTag, value);
}

(:glance, :background)
function isLogComponentEnforced(component as LogComponent) as Lang.Boolean {
    var isEnforced = forcedLogComponents().indexOf(component) != -1;
    return isEnforced;
}

(:glance, :background)
function dumpImp(tag as Lang.String, output as Lang.Object or Null) as Void {
    var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    if (newSession) {
        newSession = false;
        System.println("");
        var dateFormatted =
            info.year.format("%02d") + "/" +
            (info.month as Lang.Number).format("%02d") + "/" +
            info.day.format("%02d");

        //             "23:57:28 "
        System.println("-------- " + dateFormatted + " (" + sourceVersion() + ")");
    }

    var timePrefix =
        info.hour.format("%02d") + ":" +
        info.min.format("%02d") + ":" +
        info.sec.format("%02d") + " ";
    if (output == noArg) {
        System.println(timePrefix + tag);
    } else {
        System.println(timePrefix + tag + ": " + output);
    }
}

(:glance, :background)
var newSession as Lang.Boolean = true;
