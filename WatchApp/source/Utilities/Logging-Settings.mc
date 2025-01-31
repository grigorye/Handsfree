import Toybox.Lang;
import Toybox.Application;

(:background,:glance,:lowMemory)
function isLogAllEnforced() as Lang.Boolean {
    return false;
}

(:background,:glance,:noLowMemory)
function isLogAllEnforced() as Lang.Boolean {
    return Properties.getValue("forceLogAll") as Lang.Boolean;
}

(:noLowMemory)
function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    var components = stringComponentsJoinedBySeparator(
        AppSettings.forcedLogComponentsJoined,
        ";"
    );
    return components;
}
