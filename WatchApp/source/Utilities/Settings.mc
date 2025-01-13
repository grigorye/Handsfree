import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

(:glance, :watchApp)
module GlanceSettings {
    (:noLowMemory)
    const customGlanceTitle as Lang.String = Properties.getValue("customGlanceTitle") as Lang.String;
    (:noLowMemory)
    const isLargeFontsEnforced as Lang.Boolean = Properties.getValue("forceLargeFonts") as Lang.Boolean;
}

(:glance)
module GlanceLikeSettings {
    (:noLowMemory)
    const isShowingCallStateOnGlanceEnabled as Lang.Boolean = Properties.getValue("callStateOnGlance") as Lang.Boolean;
    (:noLowMemory)
    const isStatsTrackingEnabled as Lang.Boolean = Properties.getValue("statsTracking") as Lang.Boolean;
    const isShowingSourceVersionEnabled as Lang.Boolean = Properties.getValue("showSourceVersion") as Lang.Boolean;
    const isGlanceLoggingEnabled as Lang.Boolean = Properties.getValue("glanceLogging") as Lang.Boolean;
}

module AppSettings {
    function toggle(key as Lang.String) as Void {
        var value = Properties.getValue(key) as Lang.Boolean;
        Properties.setValue(key, !value);
    }
    
    const followUpCommDelay as Lang.Number = Properties.getValue("followUpCommDelay") as Lang.Number;
    function isOptimisticCallHandlingEnabled() as Lang.Boolean {
        return Properties.getValue("optimisticCallHandling") as Lang.Boolean;
    }
    const isExitToSystemAfterCallCompletionEnabled as Lang.Boolean = Properties.getValue("popOutOfAppInsteadOfPhones") as Lang.Boolean;

    (:noLowMemory)
    const isBeepOnCommuncationEnabled as Lang.Boolean = Properties.getValue("beepOnComm") as Lang.Boolean;
    const isMenu2NoRedrawWorkaroundEnabled as Lang.Boolean = Properties.getValue("workaroundNoRedrawForMenu2") as Lang.Boolean;
    (:noLowMemory)
    const incomingCallVibrationProgram as Lang.String = Properties.getValue("incomingCallVibration") as Lang.String;
    const isShowingPhoneNumbersEnabled as Lang.Boolean = Properties.getValue("showPhoneNumbers") as Lang.Boolean;
    const forcedLogComponentsJoined as Lang.String = Properties.getValue("forcedLogComponents") as Lang.String;

    const isFlushIncomingMessagesOnLaunchEnabled as Lang.Boolean = Properties.getValue("flushIncomingMessagesOnLaunch") as Lang.Boolean;

    (:noLowMemory)
    const isEraseAppDataOnNextLaunchEnabled as Lang.Boolean = Properties.getValue("eraseAppDataOnNextLaunch") as Lang.Boolean;
    (:noLowMemory)
    function clearEraseAppDataOnNextLaunch() as Void {
        Properties.setValue("eraseAppDataOnNextLaunch", false);
    }
}

(:background)
module BackgroundSettings {
    function broadcastListeningVersion() as Lang.Number {
        return isBroadcastListeningEnabled() ? 1 : 0;
    }

    function isBroadcastListeningEnabled() as Lang.Boolean {
        return Properties.getValue("broadcastListening") as Lang.Boolean;
    }

    function isOpenAppOnIncomingCallEnabled() as Lang.Boolean {
        return Properties.getValue("openAppOnIncomingCall") as Lang.Boolean;
    }
    const isIncomingOpenAppViaCompanionEnabled as Lang.Boolean = Properties.getValue("incomingOpenAppViaCompanion") as Lang.Boolean;
    const isIncomingOpenAppViaWakeUpEnabled as Lang.Boolean = Properties.getValue("incomingOpenAppViaWakeUp") as Lang.Boolean;
}

(:background)
module CommonSettings {
    const incomingCallMessageFormat as Lang.String = Properties.getValue("incomingCallMessageFormat") as Lang.String;
}

(:background, :glance, :noLowMemory)
function isLogAllEnforced() as Lang.Boolean {
    return Properties.getValue("forceLogAll") as Lang.Boolean;
}

(:noLowMemory)
function logComponentsForcedInApp() as Lang.Array<Lang.String> {
    var components = stringComponentsJoinedBySeparator(AppSettings.forcedLogComponentsJoined, ";");
    return components;
}
