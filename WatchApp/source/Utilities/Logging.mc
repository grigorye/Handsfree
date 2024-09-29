using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:background, :glance)
const debug = false;

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
    dumpImp(component, tag, value);
}

(:glance, :background, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function isLogComponentEnforced(component as LogComponent) as Lang.Boolean {
    var forcedComponents;
    if (component.equals(L_GLANCE) && GlanceLikeSettings.isGlanceLoggingEnabled) {
        return true;
    }
    if (!isActiveUiKindApp) {
        forcedComponents = [">", "<", "app", "openMe"];
    } else {
        forcedComponents = logComponentsForcedInApp();
    }
    return forcedComponents.indexOf(component) != -1;
}

(:glance, :background)
function dumpImp(component as LogComponent, tag as Lang.String, output as Lang.Object or Null) as Void {
    var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var timePrefix =
        info.hour.format("%02d") + ":" +
        info.min.format("%02d") + ":" +
        info.sec.format("%02d") + " ";
    var message = timePrefix + component + "." + tag;
    if (output != noArg) {
        message = message + ": " + output;
    }
    System.println(message);
}

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
