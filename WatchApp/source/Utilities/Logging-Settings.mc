import Toybox.Lang;
import Toybox.Application;

(:background, :glance, :lowMemory, :logging)
function isLogAllEnforced() as Lang.Boolean {
    return false;
}

(:background, :glance, :noLowMemory, :logging)
function isLogAllEnforced() as Lang.Boolean {
    return Properties.getValue(Settings_verboseLogsK) as Lang.Boolean;
}

(:noLowMemory, :logging)
function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    var components = stringComponentsJoinedBySeparator(
        AppSettings.forcedLogComponentsJoined,
        ";"
    );
    return components;
}
