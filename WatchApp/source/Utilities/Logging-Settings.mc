import Toybox.Lang;
import Toybox.Application;

(:background,:glance,:lowMemory)
function isLogAllEnforced() as Lang.Boolean {
    if (!isActiveUiKindApp) {
        return false;
    } else {
        return Properties.getValue("forceLogAll") as Lang.Boolean;
    }
}

(:background,:glance,:noLowMemory)
function isLogAllEnforced() as Lang.Boolean {
    return Properties.getValue("forceLogAll") as Lang.Boolean;
}

(:lowMemory)
function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    return [">", "<", "app", "openMe", viewDebug ? "commView" : ""];
}

(:noLowMemory)
function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    var components = stringComponentsJoinedBySeparator(
        AppSettings.forcedLogComponentsJoined,
        ";"
    );
    return components;
}
