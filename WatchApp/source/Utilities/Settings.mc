using Toybox.Application;
using Toybox.Lang;

(:glance)
module GlanceSettings {
    var isShowingCallStateOnGlanceEnabled as Lang.Boolean = Application.Properties.getValue("callStateOnGlance") as Lang.Boolean;
    var isShowingSourceVersionEnabled as Lang.Boolean = Application.Properties.getValue("showSourceVersion") as Lang.Boolean;
    var customGlanceTitle as Lang.String = Application.Properties.getValue("customGlanceTitle") as Lang.String;
    var isLargeFontsEnforced as Lang.Boolean = Application.Properties.getValue("forceLargeFonts") as Lang.Boolean;
}

module AppSettings {
    var initialAttemptsToCheckin as Lang.Number = Application.Properties.getValue("syncAttempts") as Lang.Number;
    var initialSecondsToCheckin as Lang.Number = Application.Properties.getValue("secondsToCheckIn") as Lang.Number;
    var isSyncingCallStateOnCheckinEnabled as Lang.Boolean = Application.Properties.getValue("syncCallStateOnLaunch") as Lang.Boolean;
    var isExitToSystemAfterCallCompletionEnabled as Lang.Boolean = Application.Properties.getValue("popOutOfAppInsteadOfPhones") as Lang.Boolean;

    var isBeepOnCommuncationEnabled as Lang.Boolean = Application.Properties.getValue("beepOnComm") as Lang.Boolean;
    var isMenu2NoRedrawWorkaroundEnabled as Lang.Boolean = Application.Properties.getValue("workaroundNoRedrawForMenu2") as Lang.Boolean;
    var incomingCallVibrationProgram as Lang.String = Application.Properties.getValue("incomingCallVibration") as Lang.String;
    var forcedLogComponentsJoined as Lang.String = Application.Properties.getValue("forcedLogComponents") as Lang.String;

    var isEraseAppDataOnNextLaunchEnabled as Lang.Boolean = Application.Properties.getValue("eraseAppDataOnNextLaunch") as Lang.Boolean;
    function clearEraseAppDataOnNextLaunch() as Void {
        Application.Properties.setValue("eraseAppDataOnNextLaunch", false);
    }
}

(:background)
module BackgroundSettings {
    var isOpenAppOnIncomingCallEnabled as Lang.Boolean = Application.Properties.getValue("openAppOnIncomingCall") as Lang.Boolean;
    var isIncomingOpenAppViaCompanionEnabled as Lang.Boolean = Application.Properties.getValue("incomingOpenAppViaCompanion") as Lang.Boolean;
    var isIncomingOpenAppViaWakeUpEnabled as Lang.Boolean = Application.Properties.getValue("incomingOpenAppViaWakeUp") as Lang.Boolean;
}

(:background, :glance)
module CommonSettings {
    var incomingCallMessageFormat as Lang.String = Application.Properties.getValue("incomingCallMessageFormat") as Lang.String;
}

(:background, :glance)
function isLogAllEnforced() as Lang.Boolean {
    if (!isActiveUiKindApp) {
        return false;
    } else {
        return Application.Properties.getValue("forceLogAll") as Lang.Boolean;
    }
}

function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    var components = stringComponentsJoinedBySeparator(AppSettings.forcedLogComponentsJoined, ";");
    return components;
}
