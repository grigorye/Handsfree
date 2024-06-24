using Toybox.Application;
using Toybox.Lang;

(:background, :glance)
function isBackgroundServiceEnabled() as Lang.Boolean {
    return Application.Properties.getValue("backgroundServiceEnabled") as Lang.Boolean;
}

function initialAttemptsToCheckin() as Lang.Number {
    return Application.Properties.getValue("syncAttempts") as Lang.Number;
}

function initialSecondsToCheckin() as Lang.Number {
    return Application.Properties.getValue("secondsToCheckIn") as Lang.Number;
}

function isSyncingCallStateOnCheckinEnabled() as Lang.Boolean {
    return Application.Properties.getValue("syncCallStateOnLaunch") as Lang.Boolean;
}

function isExitToSystemAfterCallCompletionEnabled() as Lang.Boolean {
    return Application.Properties.getValue("popOutOfAppInsteadOfPhones") as Lang.Boolean;
}

(:glance)
function isShowingCallStateOnGlanceEnabled() as Lang.Boolean {
    return Application.Properties.getValue("callStateOnGlance") as Lang.Boolean;
}

(:glance)
function isShowingSourceVersionEnabled() as Lang.Boolean {
    return Application.Properties.getValue("showSourceVersion") as Lang.Boolean;
}

(:glance)
function customGlanceTitle() as Lang.String {
    return Application.Properties.getValue("customGlanceTitle") as Lang.String;
}