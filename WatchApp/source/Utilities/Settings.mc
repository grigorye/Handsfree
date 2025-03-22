import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

(:background, :glance, :noLowMemory)
const Settings_verboseLogsK = "forceLogAll";

const Settings_optimisticCallHandlingK = "optimisticCallHandling";
(:background, :glance)
const Settings_openAppOnIncomingCallK = "openAppOnIncomingCall";
(:background, :glance)
const Settings_broadcastListeningK = "broadcastListening";
const Settings_showPhoneNumbersK = "showPhoneNumbers";
(:glance)
const Settings_showSourceVersionK = "showSourceVersion";
(:glance)
const Settings_statsTrackingK = "statsTracking";
(:noLowMemory)
const Settings_beepOnCommK = "beepOnComm";

(:background, :noLowMemory)
const Settings_incomingOpenAppViaCompanionK = "incomingOpenAppViaCompanion";

(:glance,:watchApp)
module GlanceSettings {
    (:noLowMemory)
    const customGlanceTitle as Lang.String =
        Properties.getValue("customGlanceTitle") as Lang.String;
    (:noLowMemory)
    const isLargeFontsEnforced as Lang.Boolean =
        Properties.getValue("forceLargeFonts") as Lang.Boolean;
}

(:glance)
module GlanceLikeSettings {
    const isStatsTrackingEnabled as Lang.Boolean =
        Properties.getValue(Settings_statsTrackingK) as Lang.Boolean;
    const isShowingSourceVersionEnabled as Lang.Boolean =
        Properties.getValue(Settings_showSourceVersionK) as Lang.Boolean;
    const isGlanceLoggingEnabled as Lang.Boolean =
        Properties.getValue("glanceLogging") as Lang.Boolean;
}

module AppSettings {
    function toggle(key as Lang.String) as Void {
        var value = Properties.getValue(key) as Lang.Boolean;
        Properties.setValue(key, !value);
    }

    const followUpCommDelay as Lang.Number =
        Properties.getValue("followUpCommDelay") as Lang.Number;
    function isOptimisticCallHandlingEnabled() as Lang.Boolean {
        return Properties.getValue(Settings_optimisticCallHandlingK) as Lang.Boolean;
    }
    const isExitToSystemAfterCallCompletionEnabled as Lang.Boolean = true;

    (:noLowMemory, :glance)
    function isHeadsetReportEnabled() as Lang.Boolean {
        return Properties.getValue("reportHeadset") as Lang.Boolean;
    }

    (:lowMemory)
    function isHeadsetReportEnabled() as Lang.Boolean {
        return true;
    }

    (:noLowMemory)
    const isBeepOnCommunicationEnabled as Lang.Boolean =
        Properties.getValue(Settings_beepOnCommK) as Lang.Boolean;
    const isMenu2NoRedrawWorkaroundEnabled as Lang.Boolean =
        Properties.getValue("workaroundNoRedrawForMenu2") as Lang.Boolean;
    (:noLowMemory)
    const incomingCallVibrationProgram as Lang.String =
        Properties.getValue("incomingCallVibration") as Lang.String;
    const isShowingPhoneNumbersEnabled as Lang.Boolean =
        Properties.getValue(Settings_showPhoneNumbersK) as Lang.Boolean;
    const forcedLogComponentsJoined as Lang.String =
        Properties.getValue("forcedLogComponents") as Lang.String;

    const isFlushIncomingMessagesOnLaunchEnabled as Lang.Boolean =
        Properties.getValue("flushIncomingMessagesOnLaunch") as Lang.Boolean;

    const pendingValueFormat as Lang.String =
        Properties.getValue("pendingValueFormat") as Lang.String;
}

(:background, :glance)
function isBroadcastListeningEnabled() as Lang.Boolean {
    return Properties.getValue(Settings_broadcastListeningK) as Lang.Boolean;
}

(:background)
module BackgroundSettings {
    (:glance)
    function appConfigVersion() as Lang.Number {
        var temporalBroadcastListening = (Storage.getValue(TemporalBroadcasting.Storage_temporalBroadcastListening) as Lang.Boolean | Null) == true;
        var broadcastListening = temporalBroadcastListening || isBroadcastListeningEnabled();
        var appConfigVersion =
            (broadcastListening ? 1 : 0)
            + (!lowMemory ? 2 : 0)
            + (BackgroundSettings.isOpenAppOnIncomingCallEnabled() ? 4 : 0);
        if (debug) { _3(L_APP, "appConfigVersion", appConfigVersion); }
        return appConfigVersion;
    }

    (:glance)
    function isOpenAppOnIncomingCallEnabled() as Lang.Boolean {
        return Properties.getValue(Settings_openAppOnIncomingCallK) as Lang.Boolean;
    }

    (:lowMemory)
    const isIncomingOpenAppViaCompanionEnabled = false;
    (:noLowMemory)
    const isIncomingOpenAppViaCompanionEnabled =
        Properties.getValue(Settings_incomingOpenAppViaCompanionK) as Lang.Boolean;
}

(:background)
module CommonSettings {
    const incomingCallMessageFormat as Lang.String =
        Properties.getValue("incomingCallMessageFormat") as Lang.String;
}
