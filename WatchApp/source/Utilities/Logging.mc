import Toybox.System;
import Toybox.Lang;
import Toybox.Time;

(:background, :glance, :noLowMemory)
const debug = true;

(:background, :glance)
const minDebug = true;

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
