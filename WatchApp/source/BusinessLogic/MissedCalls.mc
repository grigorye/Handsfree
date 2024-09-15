using Toybox.Lang;

(:background)
function updateMissedCallsCount() as Void {
    var missedCallsCount = missedCallsCountFromRecents(getRecents(), getLastRecentsCheckDate());
    if (missedCallsCount != getMissedCallsCount()) {
        setMissedCallsCount(missedCallsCount);
    }
}

(:background)
function missedCallsCountFromRecents(recents as Recents, lastRecentCheckDate as Lang.Number) as Lang.Number {
    var recentsCount = recents.size();
    var missedCallsCount = 0;
    for (var i = 0; i < recentsCount; i++) {
        var recent = recents[i];
        if (getRecentIsNew(recent) > 0 && getRecentType(recent) == 3 && (getRecentDate(recent) / 1000) > lastRecentCheckDate) {
            missedCallsCount += 1;
        }
    }
    return missedCallsCount;
}

function missedCallsRep() as Lang.String or Null {
    var missedCallsCount = getMissedCallsCount();
    if (missedCallsCount == 0) {
        return null;
    }
    return "(" + missedCallsCount + ")";
}
