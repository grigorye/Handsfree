using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;
using Toybox.Graphics;
using Rez.Styles;

(:glance, :watchApp, :noLowMemory)
class GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) {
        var defaultTitle = defaultTitle();
        var font = glanceFont();
        var colors = glanceColors();
        dc.setColor(colors[0], colors[1]);

        var title;
        var subtitle = null;
        if (!GlanceLikeSettings.isShowingCallStateOnGlanceEnabled || !Styles.glance_live_update.enabled) {
            title = defaultTitle;
            if (GlanceLikeSettings.isShowingSourceVersionEnabled) {
                subtitle = sourceVersion;
            }
        } else {
            var callState = loadCallState();
            if (callState instanceof CallInProgress) {
                var phone = callState.phone;
                var isIncomingCall = isIncomingCallPhone(phone);
                subtitle = getPhoneRep(phone);
                if (isIncomingCall) {
                    title = "Incoming Call";
                } else {
                    title = "Call in Progress";
                }
            } else {
                var missedRecents = getMissedRecents();
                var missedRecentsCount = missedRecents.size();
                if (missedRecentsCount > 0) {
                    title = "Missed Calls";
                    if (missedRecentsCount == 1) {
                        subtitle = getPhoneRep(missedRecents[0]);
                    } else {
                        subtitle = missedRecentsCount + " contacts";
                    }
                } else {
                    title = defaultTitle;
                    if (GlanceLikeSettings.isShowingSourceVersionEnabled) {
                        subtitle = sourceVersion;
                    } else {
                        subtitle = "Idle";
                    }
                }
            }
        }
        var text;
        if (title != null) {
            text = title;
        } else {
            text = defaultTitle;
        }
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
function defaultTitle() as Lang.String {
    var customTitle = GlanceSettings.customGlanceTitle;
    var adjustedTitle;
    if (customTitle.equals("")) {
        if (GlanceLikeSettings.isStatsTrackingEnabled) {
            adjustedTitle = "Hfree";
        } else {
            adjustedTitle = "Handsfree";
        }
    } else {
        adjustedTitle = customTitle;
    }
    var nonCapitalizedDefaultTitle = adjustedTitle;
    if (Styles.glance_live_update.enabled) {
        nonCapitalizedDefaultTitle = joinComponents([nonCapitalizedDefaultTitle, joinComponents([headsetStatusRep(), statsRep()], "")], " ");
    }
    var defaultTitle;
    if (Styles.glance_font.capitalize) {
        defaultTitle = nonCapitalizedDefaultTitle.toUpper();
    } else {
        defaultTitle = nonCapitalizedDefaultTitle;
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
