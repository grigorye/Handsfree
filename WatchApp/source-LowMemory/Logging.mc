import Toybox.Lang;
import Toybox.Application;

(:background, :glance)
const debug = false;

(:background)
function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    return [">", "<", "app", "openMe"];
}

(:background, :glance)
function isLogAllEnforced() as Lang.Boolean {
    if (!isActiveUiKindApp) {
        return false;
    } else {
        return Properties.getValue("forceLogAll") as Lang.Boolean;
    }
}
