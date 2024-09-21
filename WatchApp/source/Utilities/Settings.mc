using Toybox.Application;
using Toybox.Lang;

(:glance, :watchApp)
module GlanceSettings {
    (:noLowMemory)
    const customGlanceTitle as Lang.String = Application.Properties.getValue("customGlanceTitle") as Lang.String;
    (:noLowMemory)
    const isLargeFontsEnforced as Lang.Boolean = Application.Properties.getValue("forceLargeFonts") as Lang.Boolean;
}

(:glance)
module GlanceLikeSettings {
    (:noLowMemory)
    const isShowingCallStateOnGlanceEnabled as Lang.Boolean = Application.Properties.getValue("callStateOnGlance") as Lang.Boolean;
    (:noLowMemory)
    const isStatsTrackingEnabled as Lang.Boolean = Application.Properties.getValue("statsTracking") as Lang.Boolean;
    const isShowingSourceVersionEnabled as Lang.Boolean = Application.Properties.getValue("showSourceVersion") as Lang.Boolean;
    const isGlanceLoggingEnabled as Lang.Boolean = Application.Properties.getValue("glanceLogging") as Lang.Boolean;
}

module AppSettings {
    function toggle(key as Lang.String) as Void {
        var value = Application.Properties.getValue(key) as Lang.Boolean;
        Application.Properties.setValue(key, !value);
    }
    
    (:noLowMemory)
    const isCheckInEnabled as Lang.Boolean = Application.Properties.getValue("forceCheckIn") as Lang.Boolean;
    (:noLowMemory)
    const initialAttemptsToCheckin as Lang.Number = Application.Properties.getValue("syncAttempts") as Lang.Number;
    (:noLowMemory)
    const initialSecondsToCheckin as Lang.Number = Application.Properties.getValue("secondsToCheckIn") as Lang.Number;
    (:noLowMemory)
    const isSyncingCallStateOnCheckinEnabled as Lang.Boolean = Application.Properties.getValue("syncCallStateOnLaunch") as Lang.Boolean;
    const isOptimisticCallHandlingEnabled as Lang.Boolean = Application.Properties.getValue("optimisticCallHandling") as Lang.Boolean;
    const isExitToSystemAfterCallCompletionEnabled as Lang.Boolean = Application.Properties.getValue("popOutOfAppInsteadOfPhones") as Lang.Boolean;

    const landingScreenID as Lang.Number = Application.Properties.getValue("landingScreenID") as Lang.Number;
    
    (:noLowMemory)
    const isBeepOnCommuncationEnabled as Lang.Boolean = Application.Properties.getValue("beepOnComm") as Lang.Boolean;
    const isMenu2NoRedrawWorkaroundEnabled as Lang.Boolean = Application.Properties.getValue("workaroundNoRedrawForMenu2") as Lang.Boolean;
    (:noLowMemory)
    const incomingCallVibrationProgram as Lang.String = Application.Properties.getValue("incomingCallVibration") as Lang.String;
    const forcedLogComponentsJoined as Lang.String = Application.Properties.getValue("forcedLogComponents") as Lang.String;

    const isFlushIncomingMessagesOnLaunchEnabled as Lang.Boolean = Application.Properties.getValue("flushIncomingMessagesOnLaunch") as Lang.Boolean;

    (:noLowMemory)
    const isEraseAppDataOnNextLaunchEnabled as Lang.Boolean = Application.Properties.getValue("eraseAppDataOnNextLaunch") as Lang.Boolean;
    (:noLowMemory)
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

(:background)
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

(:noLowMemory)
function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    var components = stringComponentsJoinedBySeparator(AppSettings.forcedLogComponentsJoined, ";");
    return components;
}
