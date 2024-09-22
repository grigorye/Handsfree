using Toybox.Lang;
using Toybox.Application;

(:background)
function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    return [];
}

(:background, :glance)
function isLogAllEnforced() as Lang.Boolean {
    if (!isActiveUiKindApp) {
        return false;
    } else {
        return Application.Properties.getValue("forceLogAll") as Lang.Boolean;
    }
}
