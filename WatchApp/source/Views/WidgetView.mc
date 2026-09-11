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

        if (true) {
            var callState = getCallState();
            var lines = [] as Lang.Array<StringOrResource>;
            if (callState instanceof CallInProgress) {
                var phone = callState.phone;
                var isIncomingCall = isIncomingCallPhone(phone);
                var contactName = phone[PhoneField_name] as Lang.String or Null;
                var number = phone[PhoneField_number] as Lang.String or Null;
                var callStatusLine;
                if (isIncomingCall) {
                    callStatusLine = Rez.Strings.glanceIncomingCall;
                } else {
                    callStatusLine = Rez.Strings.glanceInProgress;
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
                        lines.add(Rez.Strings.widgetMissedCall);
                        var recents = Storage.getValue(Recents_valueKey) as Recents;
                        var recent = (recents[RecentsField_list] as RecentsList)[missedRecents[0]];
                        var recentDate = getRecentDate(recent) / 1000;
                        var dateFormatted = RecentsScreen.formatDate(recentDate);
                        var subtitle = getPhoneRep(recent);
                        if (subtitle != null) {
                            lines.add(subtitle);
                        }
                        lines.add(dateFormatted);
                    } else {
                        lines.add(Rez.Strings.glanceMissedCalls);
                        var subtitle;
                        subtitle = formatIfResources(
                            Rez.Strings.widgetContactsCountFormat,
                            [missedRecentsCount.toString()]
                        );
                        lines.add(subtitle);
                    }
                } else {
                    lines.add(Rez.Strings.listAppName);
                    var subtitle;
                    if (GlanceLikeSettings.isShowingSourceVersionEnabled) {
                        subtitle = sourceVersion;
                    } else {
                        subtitle = Rez.Strings.glanceIdle;
                    }
                    lines.add(subtitle);
                }
            }
            var headsetStatus = headsetStatusForWidget();
            if (headsetStatus != null) {
                lines.add(headsetStatus);
            }
            if (GlanceLikeSettings.isStatsTrackingEnabled) {
                var stats = statsRep();
                if (stats != null) {
                    lines.add(stats);
                }
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
function headsetStatusForWidget() as StringOrResource | Null {
    var speakerWouldBeUsed = AudioStateManip.getSpeakerWouldBeUsed();
    if (speakerWouldBeUsed == true && AppSettings.isHeadsetReportEnabled()) {
        return Rez.Strings.widgetNoHeadset;
    } else {
        return null;
    }
}