import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Application;
import Rez.Styles;

(:widget)
const L_WIDGET_VIEW as LogComponent = "widgetView";

(:widget)
class WidgetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onShow() {
        if (debug) { _2(L_WIDGET_VIEW, "onShow"); }
        View.onShow();
        widgetDidShow();
    }

    function onUpdate(dc as Graphics.Dc) {
        View.onUpdate(dc);

        if (debug) { _3(L_WIDGET_VIEW, "onUpdate", { "width" => dc.getWidth(), "height" => dc.getHeight() }); }
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

        if (debug) { _3(L_WIDGET_VIEW, "shouldShowCallState", GlanceLikeSettings.isShowingCallStateOnGlanceEnabled); }
        var appName = "Handsfree";
        if (!GlanceLikeSettings.isShowingCallStateOnGlanceEnabled) {
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
                var contactName = phone[PhoneField_name] as Lang.String or Null;
                var number = phone[PhoneField_number] as Lang.String or Null;
                var callStatusLine;
                if (isIncomingCall) {
                    callStatusLine = "Incoming Call";
                } else {
                    callStatusLine = "In Progress";
                }
                lines.add(callStatusLine);

                if (contactName != null) {
                    lines.add(contactName);
                } else if (number != null) {
                    lines.add(number);
                }
            } else {
                var missedRecents = getMissedRecents();
                var missedRecentsCount = missedRecents.size();
                if (missedRecentsCount > 0) {
                    lines.add("Missed Calls");
                    var subtitle;
                    if (missedRecentsCount == 1) {
                        var recents = Storage.getValue(Recents_valueKey) as Recents;
                        var recent = (recents[RecentsField_list] as RecentsList)[missedRecents[0]];
                        subtitle = getPhoneRep(recent);
                    } else {
                        subtitle = missedRecentsCount + " contacts";
                    }
                    lines.add(subtitle);
                } else {
                    lines.add(appName);
                    var subtitle;
                    if (GlanceLikeSettings.isShowingSourceVersionEnabled) {
                        subtitle = sourceVersion;
                    } else {
                        subtitle = "Idle";
                    }
                    lines.add(subtitle);
                }
            }
            lines.add(headsetStatusForWidget());
            if (GlanceLikeSettings.isStatsTrackingEnabled) {
                lines.add(statsRep());
            }
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
    var speakerWouldBeUsed = AudioStateManip.getSpeakerWouldBeUsed();
    if (speakerWouldBeUsed == true && AppSettings.isHeadsetReportEnabled()) {
        return "(no headset)";
    } else {
        return null;
    }
}