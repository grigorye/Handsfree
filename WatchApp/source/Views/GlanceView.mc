using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;
using Toybox.Graphics;
using Rez.Styles;

(:glance)
const L_GLANCE_VIEW as LogComponent = new LogComponent("glanceView", false);

(:glance, :typecheck(disableBackgroundCheck))
class GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onShow() {
        _([L_GLANCE_VIEW, "onShow"]);
    }

    function onHide() {
        _([L_GLANCE_VIEW, "onHide"]);
    }

    function onUpdate(dc as Graphics.Dc) {
        if (false) {
            _([L_GLANCE_VIEW, "onUpdate", { "width" => dc.getWidth(), "height" => dc.getHeight() }]);
            _([L_GLANCE_VIEW, "shouldShowCallState", isShowingCallStateOnGlanceEnabled()]);
        }
        dc.setColor(Toybox.Graphics.COLOR_WHITE, Toybox.Graphics.COLOR_TRANSPARENT);

        var defaultTitle = defaultTitle();
        var font;
        var deviceSettings = System.getDeviceSettings();
        if (isLargeFontsEnforced() || ((deviceSettings has :isEnhancedReadabilityModeEnabled) && deviceSettings.isEnhancedReadabilityModeEnabled)) {
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
        if (!isShowingCallStateOnGlanceEnabled() || !isBackgroundAppUpdateEnabled()) {
            var suffix = "";
            if (isShowingSourceVersionEnabled()) {
                suffix = "\n" + sourceVersion();
            }
            dc.drawText(
                0,
                dc.getHeight() / 2,
                font,
                defaultTitle + suffix,
                Toybox.Graphics.TEXT_JUSTIFY_LEFT | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            var callState = getCallState();
            var title;
            var subtitle;
            switch (callState) {
                case instanceof CallInProgress: {
                    var phone = (callState as CallInProgress).phone;
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
                    break;
                }
                default:
                    title = defaultTitle;
                    if (isShowingSourceVersionEnabled()) {
                        subtitle = sourceVersion();
                    } else {
                        subtitle = "Idle";
                    }
                    break;
            }

            dc.drawText(
                0,
                dc.getHeight() / 2,
                font,
                title + "\n" + subtitle,
                Toybox.Graphics.TEXT_JUSTIFY_LEFT | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }
}

(:glance)
function defaultTitle() as Lang.String {
    var customTitle = customGlanceTitle();
    var customizedTitle;
    if (customTitle.equals("")) {
        customizedTitle = WatchUi.loadResource(Rez.Strings.AppName) as Lang.String;
    } else {
        customizedTitle = customTitle;
    }
    var nonCapitalizedDefaultTitle = customizedTitle;
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
