import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Notifications;

(:background, :glance, :noLowMemory)
const Settings_verboseLogsK = "forceLogAll";

const Settings_optimisticCallHandlingK = "optimisticCallHandling";
(:background, :glance)
const Settings_openAppOnIncomingCallK = "openAppOnIncomingCall";
(:background, :watchAppBuild)
const Settings_openAppViaNotificationK = "openAppViaNotification";
(:background, :glance)
const Settings_broadcastListeningK = "broadcastListening";
const Settings_showPhoneNumbersK = "showPhoneNumbers";
(:glance, :noLowMemory)
const Settings_showSourceVersionK = "showSourceVersion";
(:glance, :noLowMemory)
const Settings_statsTrackingK = "statsTracking";
(:noLowMemory)
const Settings_beepOnCommK = "beepOnComm";

(:background, :companion)
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
    (:lowMemory)
    const isStatsTrackingEnabled as Lang.Boolean = false;
    (:noLowMemory)
    const isStatsTrackingEnabled as Lang.Boolean =
        Properties.getValue(Settings_statsTrackingK) as Lang.Boolean;
    (:lowMemory)
    const isShowingSourceVersionEnabled as Lang.Boolean = false;
    (:noLowMemory)
    const isShowingSourceVersionEnabled as Lang.Boolean =
        Properties.getValue(Settings_showSourceVersionK) as Lang.Boolean;
    (:noLowMemory)
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
    
    function isShowingPhoneNumbersEnabled() as Lang.Boolean {
        return Properties.getValue(Settings_showPhoneNumbersK) as Lang.Boolean;
    }

    (:noLowMemory)
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

(:background, :glance, :lowMemoryManifest)
const lowMemoryManifest = true;

(:background, :glance, :noLowMemoryManifest)
const lowMemoryManifest = false;

(:background)
module BackgroundSettings {
    (:glance)
    function appConfigVersion() as Lang.Number {
        var broadcastListening = TemporalBroadcasting.isBroadcastListeningActive();
        var appConfigVersion =
            (broadcastListening ? 1 : 0)
            + (!lowMemoryManifest ? 2 : 0)
            + (BackgroundSettings.isOpenAppOnIncomingCallEnabled() ? 4 : 0);
        if (debug) { _3(L_APP, "appConfigVersion", appConfigVersion); }
        return appConfigVersion;
    }

    (:glance)
    function isOpenAppOnIncomingCallEnabled() as Lang.Boolean {
        return Properties.getValue(Settings_openAppOnIncomingCallK) as Lang.Boolean;
    }

    (:watchAppBuild)
    function isOpenAppViaNotificationEnabled() as Lang.Boolean {
        if (!((Toybox has :Notifications) && (Notifications has :showNotification))) {
            return false;
        }
        return Properties.getValue(Settings_openAppViaNotificationK) as Lang.Boolean;
    }

    (:widgetBuild)
    function isOpenAppViaNotificationEnabled() as Lang.Boolean {
        return false;
    }

    (:noCompanion)
    const isIncomingOpenAppViaCompanionEnabled = false;
    (:companion)
    const isIncomingOpenAppViaCompanionEnabled =
        isFenix7 && Properties.getValue(Settings_incomingOpenAppViaCompanionK) as Lang.Boolean;
}

(:background)
module CommonSettings {
    const incomingCallMessageFormat as Lang.String =
        Properties.getValue("incomingCallMessageFormat") as Lang.String;
}
