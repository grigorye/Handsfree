import Toybox.Lang;
import Toybox.Application;

(:background)
function updateMissedRecents() as Void {
    var recents = getRecents();
    var lastRecentCheckDate = getLastRecentsCheckDate();
    var newMissedRecents = missedRecents(recents, lastRecentCheckDate);
    var oldMissedRecents = getMissedRecents();
    if (newMissedRecents.toString().equals(oldMissedRecents.toString())) {
        return;
    }
    setMissedRecents(newMissedRecents);
}

(:background)
function missedRecents(recents as Recents, lastRecentCheckDate as Lang.Number) as Recents {
    var recentsCount = recents.size();
    var missedRecents = [] as Recents;
    for (var i = 0; i < recentsCount; i++) {
        var recent = recents[i];
        if (getRecentIsNew(recent) > 0 && getRecentType(recent) == 3 && (getRecentDate(recent) / 1000) > lastRecentCheckDate) {
            missedRecents.add(recent);
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
