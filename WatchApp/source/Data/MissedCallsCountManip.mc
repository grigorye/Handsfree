import Toybox.Lang;
import Toybox.Application;

(:glance)
typedef MissedRecents as Lang.Array<Lang.Number>;

(:inline, :glance)
function getMissedRecents() as MissedRecents {
    var missedRecents = Storage.getValue(Storage_missingRecents) as MissedRecents | Null;
    if (missedRecents == null) {
        missedRecents = [] as MissedRecents;
    }
    return missedRecents;
}

(:inline, :glance)
function setMissedRecents(missedRecents as MissedRecents | Null) as Void {
    Storage.setValue(Storage_missingRecents, missedRecents as Application.PropertyValueType);
    updateUIForMissedRecentsIfInApp();
}

(:inline,:glance,:typecheck([disableGlanceCheck]))
function updateUIForMissedRecentsIfInApp() as Void {
    if (isActiveUiKindApp) {
        updateRecentsMenuItem();
        RecentsManip.updateRecentsView();
    }
}