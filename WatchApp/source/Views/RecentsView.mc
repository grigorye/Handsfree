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
        var title = joinComponents(["Recents", missedCallsRep()], " ");
        setTitle(title);
    }

    private function addMenuItemsFromRecents() as Void {
        var recents = Storage.getValue(Recents_valueKey) as Recents;
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
        addItem(accessIssueMenuItem("Recents", accessIssue, noRecentsMenuItemId));
    }

    private function addMenuItemsForEmptyRecentsList() as Void {
        if (debug) { _2(L_RECENTS_VIEW, "addMenuItemsForEmptyRecentsList"); }
        addItem(new WatchUi.MenuItem("No recents", "", noRecentsMenuItemId, {}));
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
                    label = "Private Number";
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
                typeFormatted = "!"; // missed
            } else {
                typeFormatted = formatRecentType(type);
            }
            var durationFormatted = formatDuration(getRecentDuration(recent));
            var subLabel = joinComponents([typeFormatted + " " + dateFormatted, durationFormatted], ", ");
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

function formatRecentType(type as Lang.Number) as Lang.String {
    switch (type) {
        case 1:
            return ">"; // incoming
        case 2:
            return "<"; // outgoing
        case 3:
            return "?"; // missed
        case 4:
            return "r"; // voicemail
        case 5:
            return "-"; // rejected
        case 6:
            return "b"; // blocked
        case 7:
            return "a"; // answered externally
        default:
            return type.toString();
    }
}

function formatDate(date as Lang.Number) as Lang.String {
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

function formatDuration(duration as Lang.Number) as Lang.String or Null {
    var seconds = duration;
    var minutes = seconds / 60;
    var hours = minutes / 60;
    var formatted = "";
    if (hours > 0) {
        formatted += hours.toString() + "h";
    }
    if (minutes > 0) {
        if (!formatted.equals("")) {
            formatted += " ";
        }
        formatted += (minutes % 60).toString() + "m";
    }
    if (seconds > 0) {
        if (!formatted.equals("")) {
            formatted += " ";
        }
        formatted += (seconds % 60).toString() + "s";
    }
    if (formatted.equals("")) {
        return null;
    }
    return formatted;
}

}
