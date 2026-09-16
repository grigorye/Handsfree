import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Application;

module RecentsScreen {

const L_RECENTS_VIEW as LogComponent = "recentsView";

class View extends ExtendedMenu2 {
    function initialize(lastRecentsCheckDate as Lang.Number) {
        ExtendedMenu2.initialize();
        self.lastRecentsCheckDate = lastRecentsCheckDate;
        setTitleFromRecents();
        addMenuItemsFromRecents();
    }

    private var lastRecentsCheckDate as Lang.Number;

    function update() as Void {
        if (debug) { _2(L_RECENTS_VIEW, "update"); }
        setTitleFromRecents();
        beginUpdate();
        deleteAllItems();
        addMenuItemsFromRecents();
        endUpdate();
    }

    function setTitleFromRecents() as Void {
        var missedCalls = missedCallsRep();
        var title = joinNonNullComponents([Rez.Strings.menuRecents, missedCalls], " ");
        setTitle(title);
    }

    private function addMenuItemsFromRecents() as Void {
        var recents = Storage.getValue(Recents_valueKey) as Recents | Null;
        if (recents == null) {
            recents = Recents_defaultValue;
        }
        var accessIssue = recents[RecentsField_accessIssue] as AccessIssue | Null;
        if (accessIssue != null) {
            addMenuItemsForAccessIssue(accessIssue);
        } else {
            var recentsList = recents[RecentsField_list] as RecentsList;
            if (recentsList.size() == 0) {
                addMenuItemsForEmptyRecentsList();
            } else {
                addMenuItemsForNonEmptyRecentsList(recentsList);
            }
        }
    }

    private function addMenuItemsForAccessIssue(accessIssue as AccessIssue) as Void {
        if (debug) { _2(L_RECENTS_VIEW, "addMenuItemsForAccessIssue"); }
        addItem(accessIssueMenuItem(Rez.Strings.menuRecents, accessIssue, noRecentsMenuItemId));
    }

    private function addMenuItemsForEmptyRecentsList() as Void {
        if (debug) { _2(L_RECENTS_VIEW, "addMenuItemsForEmptyRecentsList"); }
        addItem(new WatchUi.MenuItem(Rez.Strings.recentsNoRecents, "", noRecentsMenuItemId, {}));
    }

    private function addMenuItemsForNonEmptyRecentsList(recents as RecentsList) as Void {
        if (debug) { _2(L_RECENTS_VIEW, "addMenuItemsForNonEmptyRecentsList"); }
        var recentsCount = recents.size();
        for (var i = 0; i < recentsCount; i++) {
            var recent = recents[i];
            var name = getRecentName(recent);
            var label;
            if (name == null || name.equals("")) {
                var number = getRecentNumber(recent);
                if (number.equals("")) {
                    label = Rez.Strings.recentsPrivateNumber;
                } else {
                    label = getRecentNumber(recent);
                }
            } else {
                label = name;
            }
            var recentDate = getRecentDate(recent) / 1000;
            var dateFormatted = formatDate(recentDate);
            var typeFormatted;
            var type = getRecentType(recent);
            if (type == 3 && recentDate > lastRecentsCheckDate && getRecentIsNew(recent) > 0) {
                typeFormatted = Rez.Strings.recentsTypeNewMissedIndicator;
            } else {
                typeFormatted = formatRecentType(type);
            }
            var durationFormatted = formatDuration(getRecentDuration(recent));
            var summary = formatIfResources("$1$ $2$", [typeFormatted, dateFormatted]);
            var subLabel = joinNonNullComponents([summary, durationFormatted], ", ");
            var item = new WatchUi.MenuItem(
                label, // label
                subLabel, // subLabel
                recent, // identifier
                {}
            );
            addItem(item);
        }
    }
}

const noRecentsMenuItemId as Lang.Number = -1;

function formatRecentType(type as Lang.Number) as StringOrResource {
    switch (type) {
        case 1:
            return Rez.Strings.recentsTypeIncomingIndicator;
        case 2:
            return Rez.Strings.recentsTypeOutgoingIndicator;
        case 3:
            return Rez.Strings.recentsTypeMissedIndicator;
        case 4:
            return Rez.Strings.recentsTypeVoicemailIndicator;
        case 5:
            return Rez.Strings.recentsTypeRejectedIndicator;
        case 6:
            return Rez.Strings.recentsTypeBlockedIndicator;
        case 7:
            return Rez.Strings.recentsTypeAnsweredExternallyIndicator;
        default:
            return type.toString();
    }
}

(:glance)
function formatDate(date as Lang.Number) as Lang.String {
    var moment = new Time.Moment(date);
    var info = Time.Gregorian.info(moment, Time.FORMAT_MEDIUM);
    var formatted;
    if (moment.lessThan(Time.today())) {
        formatted = Lang.format(
            "$1$ $2$, $3$:$4$",
            [info.month, info.day, info.hour.format("%02d"), info.min.format("%02d")]
        );
    } else {
        formatted = Lang.format(
            "$1$:$2$",
            [info.hour.format("%02d"), info.min.format("%02d")]
        );
    }
    return formatted;
}

function formatDuration(duration as Lang.Number) as Lang.String? {
    var seconds = duration;
    var minutes = seconds / 60;
    var hours = minutes / 60;
    var secondsOnly = seconds % 60;
    var minutesOnly = (minutes % 60) + (secondsOnly + 30) / 60;
    var hoursOnly = hours + (minutesOnly + 30) / 60;
    if (hoursOnly > 0) {
        return formatIfResources(Rez.Strings.durationHoursFormat, [hoursOnly]);
    }
    if (minutesOnly > 0) {
        return formatIfResources(Rez.Strings.durationMinutesFormat, [minutesOnly]);
    }
    if (secondsOnly > 0) {
        return formatIfResources(Rez.Strings.durationSecondsFormat, [secondsOnly]);
    }
    return null;
}

}
