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

        var appName = WatchUi.loadResource(Rez.Strings.listAppName) as Lang.String;
        if (true) {
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
                    if (missedRecentsCount == 1) {
                        lines.add("Missed Call");
                        var recents = Storage.getValue(Recents_valueKey) as Recents;
                        var recent = (recents[RecentsField_list] as RecentsList)[missedRecents[0]];
                        var recentDate = getRecentDate(recent) / 1000;
                        var dateFormatted = RecentsScreen.formatDate(recentDate);
                        var subtitle = getPhoneRep(recent);
                        lines.add(subtitle);
                        lines.add(dateFormatted);
                    } else {
                        lines.add("Missed Calls");
                        var subtitle;
                        subtitle = "Contacts: " + missedRecentsCount;
                        lines.add(subtitle);
                    }
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
        return "(No Headset)";
    } else {
        return null;
    }
}