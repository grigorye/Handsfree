import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

(:background, :glance, :noLowMemory)
const Settings_verboseLogsK = "forceLogAll";

const Settings_optimisticCallHandlingK = "optimisticCallHandling";
const Settings_openAppOnIncomingCallK = "openAppOnIncomingCall";
(:background)
const Settings_broadcastListeningK = "broadcastListening";
const Settings_showPhoneNumbersK = "showPhoneNumbers";
(:glance)
const Settings_showSourceVersionK = "showSourceVersion";
(:glance)
const Settings_statsTrackingK = "statsTracking";
(:glance)
const Settings_callStateOnGlanceK = "callStateOnGlance";
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
    const isShowingCallStateOnGlanceEnabled as Lang.Boolean =
        Properties.getValue(Settings_callStateOnGlanceK) as Lang.Boolean;
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
    const isExitToSystemAfterCallCompletionEnabled as Lang.Boolean =
        Properties.getValue("popOutOfAppInsteadOfPhones") as Lang.Boolean;

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

    (:noLowMemory)
    const isEraseAppDataOnNextLaunchEnabled as Lang.Boolean =
        Properties.getValue("eraseAppDataOnNextLaunch") as Lang.Boolean;
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
        return Properties.getValue(Settings_broadcastListeningK) as Lang.Boolean;
    }

    function isOpenAppOnIncomingCallEnabled() as Lang.Boolean {
        return Properties.getValue("openAppOnIncomingCall") as Lang.Boolean;
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
