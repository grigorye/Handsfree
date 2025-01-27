import Toybox.Lang;
import Toybox.Application;

(:background)
function updateMissedRecents() as Void {
    var missedRecentsForUpdate = missedRecentsForUpdate();
    if (missedRecentsForUpdate == null) {
        _2(L_APP, "updateMissedRecents.noChange");
        return;
    }
    setMissedRecents(missedRecentsForUpdate);
}

(:background)
function missedRecentsForUpdate() as MissedRecents? {
    var recentsSubject = Storage.getValue(Recents_valueKey) as Recents | Null;
    if (recentsSubject == null) {
        return null;
    }
    var recents = recentsSubject[RecentsField_list] as RecentsList;
    var lastRecentCheckDate = getLastRecentsCheckDate();
    var newMissedRecents = missedRecents(recents, lastRecentCheckDate);
    var oldMissedRecents = getMissedRecents();
    if (objectsEqual(newMissedRecents, oldMissedRecents)) {
        return null;
    } else {
        return newMissedRecents;
    }
}

(:background)
function missedRecents(recents as RecentsList, lastRecentCheckDate as Lang.Number) as MissedRecents {
    var recentsCount = recents.size();
    var missedRecents = [] as MissedRecents;
    for (var i = 0; i < recentsCount; i++) {
        var recent = recents[i];
        if (getRecentIsNew(recent) > 0 && getRecentType(recent) == 3 && (getRecentDate(recent) / 1000) > lastRecentCheckDate) {
            missedRecents.add(i);
        }
    }
    if (debug) { _3(L_APP, "missedRecents", missedRecents); }
    return missedRecents;
}

function missedCallsRep() as Lang.String or Null {
    var missedRecents = getMissedRecents();
    if (missedRecents.size() == 0) {
        return null;
    }
    return "(" + missedRecents.size() + ")";
}
