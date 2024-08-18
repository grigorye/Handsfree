using Toybox.Application;
using Toybox.Lang;

(:glance, :watchApp)
module GlanceSettings {
    const customGlanceTitle as Lang.String = Application.Properties.getValue("customGlanceTitle") as Lang.String;
    const isLargeFontsEnforced as Lang.Boolean = Application.Properties.getValue("forceLargeFonts") as Lang.Boolean;
}

(:glance)
module GlanceLikeSettings {
    const isShowingCallStateOnGlanceEnabled as Lang.Boolean = Application.Properties.getValue("callStateOnGlance") as Lang.Boolean;
    const isShowingSourceVersionEnabled as Lang.Boolean = Application.Properties.getValue("showSourceVersion") as Lang.Boolean;
}

module AppSettings {
    const initialAttemptsToCheckin as Lang.Number = Application.Properties.getValue("syncAttempts") as Lang.Number;
    const initialSecondsToCheckin as Lang.Number = Application.Properties.getValue("secondsToCheckIn") as Lang.Number;
    const isSyncingCallStateOnCheckinEnabled as Lang.Boolean = Application.Properties.getValue("syncCallStateOnLaunch") as Lang.Boolean;
    const isOptimisticCallHandlingEnabled as Lang.Boolean = Application.Properties.getValue("optimisticCallHandling") as Lang.Boolean;
    const isExitToSystemAfterCallCompletionEnabled as Lang.Boolean = Application.Properties.getValue("popOutOfAppInsteadOfPhones") as Lang.Boolean;

    const isBeepOnCommuncationEnabled as Lang.Boolean = Application.Properties.getValue("beepOnComm") as Lang.Boolean;
    const isMenu2NoRedrawWorkaroundEnabled as Lang.Boolean = Application.Properties.getValue("workaroundNoRedrawForMenu2") as Lang.Boolean;
    const incomingCallVibrationProgram as Lang.String = Application.Properties.getValue("incomingCallVibration") as Lang.String;
    const forcedLogComponentsJoined as Lang.String = Application.Properties.getValue("forcedLogComponents") as Lang.String;

    const isFlushIncomingMessagesOnLaunchEnabled as Lang.Boolean = Application.Properties.getValue("flushIncomingMessagesOnLaunch") as Lang.Boolean;

    const isEraseAppDataOnNextLaunchEnabled as Lang.Boolean = Application.Properties.getValue("eraseAppDataOnNextLaunch") as Lang.Boolean;
    function clearEraseAppDataOnNextLaunch() as Void {
        Application.Properties.setValue("eraseAppDataOnNextLaunch", false);
    }
}

(:background)
module BackgroundSettings {
    const isOpenAppOnIncomingCallEnabled as Lang.Boolean = Application.Properties.getValue("openAppOnIncomingCall") as Lang.Boolean;
    const isIncomingOpenAppViaCompanionEnabled as Lang.Boolean = Application.Properties.getValue("incomingOpenAppViaCompanion") as Lang.Boolean;
    const isIncomingOpenAppViaWakeUpEnabled as Lang.Boolean = Application.Properties.getValue("incomingOpenAppViaWakeUp") as Lang.Boolean;
}

(:background, :glance)
module CommonSettings {
    const incomingCallMessageFormat as Lang.String = Application.Properties.getValue("incomingCallMessageFormat") as Lang.String;
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
