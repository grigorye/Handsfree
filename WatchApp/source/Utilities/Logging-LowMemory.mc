import Toybox.Lang;
import Toybox.Application;

(:background, :glance, :lowMemory)
const debug = false;

(:background, :lowMemory)
function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    return [">", "<", "app", "openMe"];
}

(:background, :glance, :lowMemory)
function isLogAllEnforced() as Lang.Boolean {
    if (!isActiveUiKindApp) {
        return false;
    } else {
        return Properties.getValue("forceLogAll") as Lang.Boolean;
    }
}
