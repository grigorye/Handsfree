using Toybox.Lang;
using Toybox.System;

(:glance, :background, :watchApp)
function appType() as Lang.String {
    return "watchApp";
}

(:glance, :background, :watchApp)
function isInWidgetMode() as Lang.Boolean {
    return false;
}

(:glance, :background, :widget)
function appType() as Lang.String {
    return "widget";
}

(:glance, :background, :widget)
function isInWidgetMode() as Lang.Boolean {
    if (System.DeviceSettings has :isGlanceModeEnabled) {
        return false;
    } else {
        return true;
    }
}

(:glance, :background)
function isGlanceModeEnabled() as Lang.Boolean or Null {
    if (System.DeviceSettings has :isGlanceModeEnabled) {
        return System.getDeviceSettings().isGlanceModeEnabled;
    } else {
        return null;
    }
}
