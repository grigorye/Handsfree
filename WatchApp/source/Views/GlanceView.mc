import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Time;
import Rez.Styles;

(:glance)
const L_GLANCE as LogComponent = "glance";

(:glance, :watchApp, :noLowMemory)
const liveGlanceSubjects = phoneStateSubject + recentsSubject + audioStateSubject;

(:glance, :watchApp, :noLowMemory)
class GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) {
        var phoneConnected = System.getDeviceSettings().phoneConnected;
        var companionStatus = companionStatus();
        var defaultTitle = defaultTitle(phoneConnected, companionStatus == CompanionStatus_upToDate);
        var font = glanceFont();
        var colors = glanceColors();
        dc.setColor(colors[0], colors[1]);

        var title;
        var subtitle = null;
        if (!phoneConnected) {
            title = defaultTitle;
            subtitle = "Not Connected";
        } else if (companionStatus != CompanionStatus_upToDate) {
            title = defaultTitle;
            subtitle = companionStatus == CompanionStatus_notInstalled ? "No Companion" : "Update Companion";
        } else if (!Styles.glance_live_update.enabled || !allSubjectsConfirmed(liveGlanceSubjects)) {
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
                    if (missedRecentsCount == 1) {
                        var recents = Storage.getValue(Recents_valueKey) as Recents;
                        var recent = (recents[RecentsField_list] as RecentsList)[missedRecents[0]];
                        var recentDate = getRecentDate(recent) / 1000;
                        var dateFormatted = RecentsScreen.formatDate(recentDate);
                        title = "! " + dateFormatted;
                        subtitle = getPhoneRep(recent);
                    } else {
                        title = "Missed Calls";
                        subtitle = missedRecentsCount + " Contacts";
                    }
                } else {
                    title = defaultTitle;
                    if (!ReadinessInfoManip.readiness(ReadinessField_essentials).equals(ReadinessValue_ready)) {
                        subtitle = "No Call Control";
                    } else {
                        var readiness = ReadinessInfoManip.readiness(ReadinessField_incomingCalls);
                        if (!readiness.equals(ReadinessValue_ready)) {
                            subtitle = "Not Ready";
                        } else if (GlanceLikeSettings.isShowingSourceVersionEnabled) {
                            subtitle = sourceVersion;
                        } else {
                            subtitle = "Idle";
                        }
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
        adjustedTitle = WatchUi.loadResource(Rez.Strings.listAppName) as Lang.String;
    } else {
        adjustedTitle = customTitle;
    }
    return adjustedTitle;
}

(:glance, :watchApp, :noLowMemory)
function defaultTitle(phoneConnected as Lang.Boolean, isCompanionUpToDate as Lang.Boolean) as Lang.String {
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
            if (isCompanionUpToDate && callControlReady && AppSettings.isHeadsetReportEnabled() && allSubjectsConfirmed(liveGlanceSubjects)) {
                var headsetStatus = headsetStatusHumanReadable();
                defaultTitle = headsetStatus != null ? headsetStatus : defaultTitle;
            }
        }
    }
    return defaultTitle;
}

(:glance, :watchApp, :noLowMemory)
function formatDateOnGlance(date as Lang.Number) as Lang.String {
    var moment = new Time.Moment(date);
    var info = Time.Gregorian.info(moment, Time.FORMAT_MEDIUM);
    var formatted;
    if (moment.lessThan(Time.today())) {
        formatted = info.month + " " + info.day + ", " + info.hour.format("%02d") + ":" + info.min.format("%02d");
    } else {
        formatted = info.hour.format("%02d") + ":" + info.min.format("%02d");
    }
    return formatted;
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
