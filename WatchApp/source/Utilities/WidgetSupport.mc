using Toybox.Lang;
using Toybox.System;

(:glance, :background, :watchApp)
const appType as Lang.String = "watchApp";

(:glance, :background, :watchApp)
function isInWidgetMode() as Lang.Boolean {
    return false;
}

(:glance, :background, :widget)
const appType as Lang.String = "widget";

(:glance, :background, :widget)
function isInWidgetMode() as Lang.Boolean {
    return !(System.DeviceSettings has :isGlanceModeEnabled);
}

(:glance, :background, :watchApp)
const isBuiltAsWidget as Lang.Boolean = false;
(:glance, :background, :widget)
const isBuiltAsWidget as Lang.Boolean = true;

(:glance, :background)
function isGlanceModeEnabled() as Lang.Boolean or Null {
    if (System.DeviceSettings has :isGlanceModeEnabled) {
        return System.getDeviceSettings().isGlanceModeEnabled;
    } else {
        return null;
    }
}
