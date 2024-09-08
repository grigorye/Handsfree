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
        var font;
        var deviceSettings = System.getDeviceSettings();
        if (GlanceSettings.isLargeFontsEnforced || ((deviceSettings has :isEnhancedReadabilityModeEnabled) && deviceSettings.isEnhancedReadabilityModeEnabled)) {
            font = Styles.glance_font.fontEnhanced;
        } else {
            font = Styles.glance_font.font;
        }
        var foregroundColor;
        var backgroundColor;
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
        dc.setColor(foregroundColor, backgroundColor);

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
                var phoneName = phone["name"] as Lang.String or Null;
                var number = phone["number"] as Lang.String or Null;
                if (phoneName != null) {
                    subtitle = phoneName;
                } else if (number != null) {
                    subtitle = number;
                } else {
                    subtitle = null;
                }
                if (isIncomingCall) {
                    title = "Incoming Call";
                } else {
                    title = "Call in Progress";
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
        var text = title;
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
        adjustedTitle = "Handsfree";
    } else {
        adjustedTitle = customTitle;
    }
    var nonCapitalizedDefaultTitle = adjustedTitle;
    if (Styles.glance_live_update.enabled) {
        nonCapitalizedDefaultTitle = joinComponents([nonCapitalizedDefaultTitle, headsetStatusRep()], " ");
    }
    var defaultTitle;
    if (Styles.glance_font.capitalize) {
        defaultTitle = nonCapitalizedDefaultTitle.toUpper();
    } else {
        defaultTitle = nonCapitalizedDefaultTitle;
    }
    return defaultTitle;
}