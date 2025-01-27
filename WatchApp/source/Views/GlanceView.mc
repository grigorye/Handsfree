import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Graphics;
import Toybox.Application;
import Rez.Styles;

(:glance)
const L_GLANCE as LogComponent = "glance";

(:glance, :watchApp, :noLowMemory)
class GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) {
        var phoneConnected = System.getDeviceSettings().phoneConnected;
        var companionConnected = Storage.getValue(CompanionInfo_valueKey) != null;
        var defaultTitle = defaultTitle(phoneConnected, companionConnected);
        var font = glanceFont();
        var colors = glanceColors();
        dc.setColor(colors[0], colors[1]);

        var title;
        var subtitle = null;
        if (!phoneConnected) {
            title = defaultTitle;
            subtitle = "Not connected";
        } else if (!companionConnected) {
            title = defaultTitle;
            subtitle = "No companion";
        } else if (!GlanceLikeSettings.isShowingCallStateOnGlanceEnabled || !Styles.glance_live_update.enabled) {
            title = defaultTitle;
            if (GlanceLikeSettings.isShowingSourceVersionEnabled) {
                subtitle = sourceVersion;
            }
        } else {
            var callState = loadCallState();
            if (debug) { _3(L_GLANCE, "callState", callState); }
            if (callState instanceof CallInProgress) {
                var phone = callState.phone;
                var isIncomingCall = isIncomingCallPhone(phone);
                subtitle = getPhoneRep(phone);
                if (isIncomingCall) {
                    title = "Incoming Call";
                } else {
                    title = "In Progress";
                }
            } else {
                var missedRecents = getMissedRecents();
                var missedRecentsCount = missedRecents.size();
                if (missedRecentsCount > 0) {
                    title = "Missed Calls";
                    if (missedRecentsCount == 1) {
                        var recents = Storage.getValue(Recents_valueKey) as Recents;
                        var recent = (recents[RecentsField_list] as RecentsList)[missedRecents[0]];
                        subtitle = getPhoneRep(recent);
                    } else {
                        subtitle = missedRecentsCount + " contacts";
                    }
                } else {
                    title = defaultTitle;
                    if (!ReadinessInfoManip.readiness(ReadinessField_essentials).equals(ReadinessValue_ready)) {
                        subtitle = "No call control";
                    } else if (GlanceLikeSettings.isShowingSourceVersionEnabled) {
                        subtitle = sourceVersion;
                    } else {
                        subtitle = "Idle";
                    }
                }
            }
        }
        var text;
        if (title.equals(defaultTitle)) {
            text = title;
        } else {
            text = embeddingHeadsetStatusRep(title);
        }
        if (Styles.glance_font.capitalize) {
            text = text.toUpper();
        }
        if (debug) { _3(L_GLANCE, "text", [text, subtitle]); }
        if (subtitle != null) {
            text = text + "\n" + subtitle;
        }
        dc.drawText(
            0,
            dc.getHeight() / 2,
            font,
            text,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

(:glance, :watchApp, :noLowMemory)
function customizableTitle() as Lang.String {
    var customTitle = GlanceSettings.customGlanceTitle;
    var adjustedTitle;
    if (customTitle.equals("")) {
        if (GlanceLikeSettings.isStatsTrackingEnabled) {
            adjustedTitle = "HFree";
        } else {
            adjustedTitle = "Handsfree";
        }
    } else {
        adjustedTitle = customTitle;
    }
    return adjustedTitle;
}

(:glance, :watchApp, :noLowMemory)
function defaultTitle(phoneConnected as Lang.Boolean, companionConnected as Lang.Boolean) as Lang.String {
    var defaultTitle = customizableTitle();
    if (!phoneConnected) {
        return defaultTitle;
    }
    if (Styles.glance_live_update.enabled) {
        var statsRep = statsRep();
        if (statsRep != null) {
            defaultTitle = embeddingHeadsetStatusRep(statsRep);
        } else {
            var callControlReady = ReadinessInfoManip.readiness(ReadinessField_essentials).equals(ReadinessValue_ready);
            if (companionConnected && callControlReady) {
                var headsetStatus = headsetStatusHumanReadable();
                defaultTitle = headsetStatus != null ? headsetStatus : defaultTitle;
            }
        }
    }
    return defaultTitle;
}

(:glance, :watchApp, :noLowMemory)
function glanceFont() as Graphics.FontDefinition or Graphics.VectorFont {
    var font;
    var deviceSettings = System.getDeviceSettings();
    if (GlanceSettings.isLargeFontsEnforced || ((deviceSettings has :isEnhancedReadabilityModeEnabled) && deviceSettings.isEnhancedReadabilityModeEnabled)) {
        font = Styles.glance_font.fontEnhanced;
    } else {
        var fontScale = glanceFontScale();
        if (Graphics has :getVectorFont) {
            var vectorFont = Graphics.getVectorFont({
                :face => ["RobotoCondensedBold"],
                :size => 26 * fontScale
            });
            if (vectorFont != null) {
                return vectorFont;
            }
        }
        font = Styles.glance_font.font;
    }
    return font;
}

(:glance, :watchApp, :noLowMemory)
function glanceFontScale() as Lang.Float {
    var deviceSettings = System.getDeviceSettings();
    if (deviceSettings has :fontScale) {
        return deviceSettings.fontScale;
    }
    return 1.0;
}

(:glance, :watchApp, :noLowMemory)
function glanceColors() as Lang.Array<Graphics.ColorValue> {
    var foregroundColor;
    var backgroundColor;
    var deviceSettings = System.getDeviceSettings();
    if (deviceSettings has :isNightModeEnabled) {
        if (deviceSettings.isNightModeEnabled) {
            foregroundColor = Graphics.COLOR_WHITE;
            backgroundColor = Graphics.COLOR_BLACK;
        } else {
            foregroundColor = Graphics.COLOR_BLACK;
            backgroundColor = Graphics.COLOR_WHITE;
        }
    } else {
        foregroundColor = Graphics.COLOR_WHITE;
        backgroundColor = Graphics.COLOR_TRANSPARENT;
    }
    return [foregroundColor, backgroundColor];
}
