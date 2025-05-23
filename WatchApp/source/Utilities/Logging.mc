import Toybox.System;
import Toybox.Lang;
import Toybox.Time;

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
    if (isLogComponentSuppressed(component)) {
        return;
    }
    dumpImp(component, tag, value);
}

(:glance, :background, :lowMemory)
function isLogComponentEnforced(component as LogComponent) as Lang.Boolean {
    var forcedComponents = [">", "<", "app", "openMe", (viewDebug && isActiveUiKindApp) ? "commView" : ""];
    return forcedComponents.indexOf(component) != -1;
}

(:glance, :background, :typecheck([disableBackgroundCheck, disableGlanceCheck]),:noLowMemory)
function isLogComponentEnforced(component as LogComponent) as Lang.Boolean {
    var forcedComponents;
    if (!isActiveUiKindApp) {
        forcedComponents = [">", "<", "app", "openMe"];
    } else {
        forcedComponents = logComponentsForcedInApp();
    }
    return forcedComponents.indexOf(component) != -1;
}

(:glance, :background, :typecheck([disableBackgroundCheck, disableGlanceCheck]),:noLowMemory)
function isLogComponentSuppressed(component as Lang.String) as Lang.Boolean {
    if (component.equals(L_GLANCE)) {
        return !GlanceLikeSettings.isGlanceLoggingEnabled;
    }
    return false;
}

(:glance, :background, :lowMemory)
function isLogComponentSuppressed(component as Lang.String) as Lang.Boolean {
    return false;
}

(:glance, :background)
function dumpImp(component as LogComponent, tag as Lang.String, output as Lang.Object | Null) as Void {
    var prefix;
    if (!lowMemory) {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var timePrefix =
            info.hour.format("%02d") + ":" +
            info.min.format("%02d") + ":" +
            info.sec.format("%02d") + " ";
        prefix = timePrefix + component + "." + tag;
    } else {
        prefix = component + "." + tag;
    }
    var message;
    if (output == noArg) {
        message = prefix;
    } else {
        message = prefix + ": " + output;
    }
    System.println(message);
}
