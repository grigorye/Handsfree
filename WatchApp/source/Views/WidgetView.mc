using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;
using Toybox.Graphics;
import Rez.Styles;

(:watchApp)
class WidgetView extends WatchUi.View {
    function initialize() {
        View.initialize();
        System.error("reachedStubForWidgetView");
    }
}

(:widget)
class WidgetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        View.onUpdate(dc);

        dump("widgetOnUpdate", { "width" => dc.getWidth(), "height" => dc.getHeight() });
        var deviceSettings = System.getDeviceSettings();
        if (deviceSettings has :isNightModeEnabled) {
            if (deviceSettings.isNightModeEnabled) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            } else {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
            }
        } else {
            dc.setColor(Toybox.Graphics.COLOR_WHITE, Toybox.Graphics.COLOR_TRANSPARENT);
        }

        dump("shouldShowCallState", isShowingCallStateOnGlanceEnabled());
        var appName = WatchUi.loadResource(Rez.Strings.AppName) as Lang.String;
        if (!isShowingCallStateOnGlanceEnabled()) {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Styles.widget_font__title.font,
                appName + "\n" + headsetStatusForWidget(),
                Toybox.Graphics.TEXT_JUSTIFY_CENTER | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            var callState = getCallState();
            var lines = [] as Lang.Array<Lang.String>;
            switch (callState) {
                case instanceof CallInProgress: {
                    var phone = (callState as CallInProgress).phone;
                    var isIncomingCall = isIncomingCallPhone(phone);
                    var contactName = phone["name"] as Lang.String or Null;
                    var number = phone["number"] as Lang.String or Null;
                    var callStatusLine;
                    if (isIncomingCall) {
                        callStatusLine = "Incoming call";
                    } else {
                        callStatusLine = "Call in progress";
                    }
                    lines.add(callStatusLine);

                    if (contactName != null) {
                        lines.add(contactName);
                    } else if (number != null) {
                        lines.add(number);
                    }
                    break;
                }
                default: {
                    lines.add(appName);
                    var subtitle;
                    if (isShowingSourceVersionEnabled()) {
                        subtitle = sourceVersion();
                    } else {
                        subtitle = "Idle";
                    }
                    lines.add(subtitle);
                    break;
                }
            }
            var headsetStatus = headsetStatusForWidget();
            if (!headsetStatus.equals("")) {
                lines.add(headsetStatus);
            }
            var text = lines[0];
            for (var i = 1; i < lines.size(); i++) {
                text = text + "\n" + lines[i];
            }
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Styles.widget_font__title.font,
                text,
                Toybox.Graphics.TEXT_JUSTIFY_CENTER | Toybox.Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }
}

function headsetStatusForWidget() as Lang.String {
    if (!getIsHeadsetConnected()) {
        return "(no headset)";
    } else {
        return "";
    }
}