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

(:glance)
function isLargeFontsEnforced() as Lang.Boolean {
    return Application.Properties.getValue("forceLargeFonts") as Lang.Boolean;
}

(:background, :glance)
function isEraseAppDataOnNextLaunchEnabled() as Lang.Boolean {
    return Application.Properties.getValue("eraseAppDataOnNextLaunch") as Lang.Boolean;
}

(:background, :glance)
function clearEraseAppDataOnNextLaunch() as Void {
    Application.Properties.setValue("eraseAppDataOnNextLaunch", false);
}

(:background, :glance)
function isOpenAppOnIncomingCallEnabled() as Lang.Boolean {
    return Application.Properties.getValue("openAppOnIncomingCall") as Lang.Boolean;
}

(:background, :glance)
function isIncomingOpenAppViaCompanionEnabled() as Lang.Boolean {
    return Application.Properties.getValue("incomingOpenAppViaCompanion") as Lang.Boolean;
}

(:background, :glance)
function isIncomingOpenAppViaWakeUpEnabled() as Lang.Boolean {
    return Application.Properties.getValue("incomingOpenAppViaWakeUp") as Lang.Boolean;
}

(:background, :glance)
function incomingCallMessageFormat() as Lang.String {
    return Application.Properties.getValue("incomingCallMessageFormat") as Lang.String;
}

(:background, :glance)
function isBeepOnCommuncationEnabled() as Lang.Boolean {
    return Application.Properties.getValue("beepOnComm") as Lang.Boolean;
}

(:background, :glance)
function isMenu2NoRedrawWorkaroundEnabled() as Lang.Boolean {
    return Application.Properties.getValue("workaroundNoRedrawForMenu2") as Lang.Boolean;
}

(:background, :glance)
function isCompanionOnboardingEnabled() as Lang.Boolean {
    return Application.Properties.getValue("companionOnboardingEnabled") as Lang.Boolean;
}
