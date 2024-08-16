using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;
using Toybox.Graphics;
using Rez.Styles;

(:glance, :watchApp)
const L_GLANCE_VIEW as LogComponent = "glanceView";

(:glance, :watchApp)
class GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var defaultTitle = defaultTitle();
        var font;
        var deviceSettings = System.getDeviceSettings();
        if (GlanceSettings.isLargeFontsEnforced || ((deviceSettings has :isEnhancedReadabilityModeEnabled) && deviceSettings.isEnhancedReadabilityModeEnabled)) {
            font = Styles.glance_font.fontEnhanced;
        } else {
            font = Styles.glance_font.font;
        }
        if (deviceSettings has :isNightModeEnabled) {
            if (deviceSettings.isNightModeEnabled) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            } else {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
            }
        }
        if (!GlanceLikeSettings.isShowingCallStateOnGlanceEnabled || !isBackgroundAppUpdateEnabled()) {
            var suffix = "";
            if (GlanceLikeSettings.isShowingSourceVersionEnabled) {
                suffix = "\n" + sourceVersion;
            }
            dc.drawText(
                0,
                dc.getHeight() / 2,
                font,
                defaultTitle + suffix,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            var callState = loadCallState();
            var title;
            var subtitle;
            if (callState instanceof CallInProgress) {
                var phone = callState.phone;
                var isIncomingCall = isIncomingCallPhone(phone);
                title = phone["name"] as Lang.String or Null;
                if (title == null) {
                    title = defaultTitle;
                }
                var number = phone["number"] as Lang.String or Null;
                if (isIncomingCall) {
                    if (number != null) {
                        subtitle = incomingCallMessage(number);
                    } else {
                        subtitle = "Incoming call";
                    }
                } else {
                    if (number != null) {
                        subtitle = number;
                    } else {
                        subtitle = "Call in progress";
                    }
                }
            } else {
                title = defaultTitle;
                if (GlanceLikeSettings.isShowingSourceVersionEnabled) {
                    subtitle = sourceVersion;
                } else {
                    subtitle = "Idle";
                }
            }

            dc.drawText(
                0,
                dc.getHeight() / 2,
                font,
                title + "\n" + subtitle,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }
}

(:glance, :watchApp)
function defaultTitle() as Lang.String {
    var customTitle = GlanceSettings.customGlanceTitle;
    var adjustedTitle;
    if (customTitle.equals("")) {
        adjustedTitle = "Handsfree";
    } else {
        adjustedTitle = customTitle;
    }
    var nonCapitalizedDefaultTitle = adjustedTitle;
    if (isBackgroundAppUpdateEnabled()) {
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

(:glance)
function headsetStatusRep() as Lang.String or Null {
    if (!getIsHeadsetConnected()) {
        return "#";
    } else {
        return null;
    }
}
