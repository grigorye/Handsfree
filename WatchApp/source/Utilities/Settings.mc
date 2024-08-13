using Toybox.Application;
using Toybox.Lang;

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

(:background)
function isEraseAppDataOnNextLaunchEnabled() as Lang.Boolean {
    return Application.Properties.getValue("eraseAppDataOnNextLaunch") as Lang.Boolean;
}

(:background)
function clearEraseAppDataOnNextLaunch() as Void {
    Application.Properties.setValue("eraseAppDataOnNextLaunch", false);
}

(:background)
function isOpenAppOnIncomingCallEnabled() as Lang.Boolean {
    return Application.Properties.getValue("openAppOnIncomingCall") as Lang.Boolean;
}

(:background)
function isIncomingOpenAppViaCompanionEnabled() as Lang.Boolean {
    return Application.Properties.getValue("incomingOpenAppViaCompanion") as Lang.Boolean;
}

(:background)
function isIncomingOpenAppViaWakeUpEnabled() as Lang.Boolean {
    return Application.Properties.getValue("incomingOpenAppViaWakeUp") as Lang.Boolean;
}

(:background, :glance)
function incomingCallMessageFormat() as Lang.String {
    return Application.Properties.getValue("incomingCallMessageFormat") as Lang.String;
}

function isBeepOnCommuncationEnabled() as Lang.Boolean {
    return Application.Properties.getValue("beepOnComm") as Lang.Boolean;
}

function isMenu2NoRedrawWorkaroundEnabled() as Lang.Boolean {
    return Application.Properties.getValue("workaroundNoRedrawForMenu2") as Lang.Boolean;
}

(:background)
function isCompanionOnboardingEnabled() as Lang.Boolean {
    if (getActiveUiKind().equals(ACTIVE_UI_NONE)) {
        return false;
    } else {
        return Application.Properties.getValue("companionOnboardingEnabled") as Lang.Boolean;
    }
}

function incomingCallVibrationProgram() as Lang.String {
    return Application.Properties.getValue("incomingCallVibration") as Lang.String;
}

(:background, :glance)
function isLogAllEnforced() as Lang.Boolean {
    if (getActiveUiKind().equals(ACTIVE_UI_NONE)) {
        return true;
    } else {
        return Application.Properties.getValue("forceLogAll") as Lang.Boolean;
    }
}

(:background, :glance)
function forcedLogComponentsJoined() as Lang.String {
    return Application.Properties.getValue("forcedLogComponents") as Lang.String;
}

(:background, :glance)
function forcedLogComponents() as Lang.Array<Lang.String> {
    var components = stringComponentsJoinedBySeparator(forcedLogComponentsJoined(), ";");
    return components;
}
