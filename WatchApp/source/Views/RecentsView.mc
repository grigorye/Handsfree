using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;

const L_RECENTS_VIEW as LogComponent = "recentsView";

class RecentsView extends WatchUi.Menu2 {
    function initialize(recents as Recents) {
        WatchUi.Menu2.initialize({ :title => "Recents" });
        setFromRecents(recents);
    }

    private var oldRecents as Recents = [] as Recents;

    function updateFromRecents(recents as Recents) as Void {
        _3(L_RECENTS_VIEW, "updatingFromRecents", recents);
        if (oldRecents.toString().equals(recents.toString())) {
            _2(L_RECENTS_VIEW, "recentsNotChanged");
            return;
        }
        deleteExistingItems();
        setFromRecents(recents);
        workaroundNoRedrawForMenu2(self);
    }

    function deleteExistingItems() as Void {
        var oldRecentsCount = oldRecents.size();
        var menuItemCount;
        if (oldRecentsCount == 0) {
            menuItemCount = 1; // There should be a "No recents" item
        } else {
            menuItemCount = oldRecentsCount;
        }
        for (var i = 0; i < menuItemCount; i++) {
            var existed = deleteItem(0);
            if (existed == null) {
                System.error("Failed to delete menu item at index " + i);
            }
        }
    }

    function setFromRecents(recents as Recents) as Void {
        _3(L_RECENTS_VIEW, "settingFromRecents", recents);
        var recentsCount = recents.size();
        if (recentsCount > 0) {
            for (var i = 0; i < recentsCount; i++) {
                var recent = recents[i];
                var name = getRecentName(recent);
                var label;
                if (name == null || name.equals("")) {
                    label = getRecentNumber(recent);
                } else {
                    label = name;
                }
                var dateFormatted = formatDate(getRecentDate(recent) / 1000);
                var typeFormatted = formatRecentType(getRecentType(recent));
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
        } else {
            addItem(new WatchUi.MenuItem("No recents", "", noRecentsMenuItemId, {}));
        }
        oldRecents = recents;
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