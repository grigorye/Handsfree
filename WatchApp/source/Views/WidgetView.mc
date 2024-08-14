using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.Graphics;
using Rez.Styles;

(:widget)
const L_WIDGET_VIEW as LogComponent = "widgetView";

(:widget)
class WidgetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onShow() {
        _2(L_WIDGET_VIEW, "onShow");
        View.onShow();
        widgetDidShow();
    }

    function onUpdate(dc as Graphics.Dc) {
        View.onUpdate(dc);

        _3(L_WIDGET_VIEW, "onUpdate", { "width" => dc.getWidth(), "height" => dc.getHeight() });
        var deviceSettings = System.getDeviceSettings();
        if (deviceSettings has :isNightModeEnabled) {
            if (deviceSettings.isNightModeEnabled) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            } else {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
            }
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        }

        _3(L_WIDGET_VIEW, "shouldShowCallState", isShowingCallStateOnGlanceEnabled());
        var appName = WatchUi.loadResource(Rez.Strings.AppName) as Lang.String;
        if (!isShowingCallStateOnGlanceEnabled()) {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Styles.widget_font__title.font,
                joinComponents([appName, headsetStatusForWidget()], "\n"),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            var callState = getCallState();
            var lines = [] as Lang.Array<Lang.String or Null>;
            if (callState instanceof CallInProgress) {
                var phone = callState.phone;
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
            } else {
                lines.add(appName);
                var subtitle;
                if (isShowingSourceVersionEnabled()) {
                    subtitle = sourceVersion();
                } else {
                    subtitle = "Idle";
                }
                lines.add(subtitle);
            }
            lines.add(headsetStatusForWidget());
            var text = joinComponents(lines, "\n");
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2,
                Styles.widget_font__title.font,
                text,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }
}

(:widget)
function headsetStatusForWidget() as Lang.String or Null {
    if (!getIsHeadsetConnected()) {
        return "(no headset)";
    } else {
        return null;
    }
}