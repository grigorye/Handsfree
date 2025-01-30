import Toybox.Lang;
import Toybox.Application;

(:glance)
const MissedRecents_valueKey = "missedRecents.v1";

(:glance)
typedef MissedRecents as Lang.Array<Lang.Number>;

(:inline, :glance)
function getMissedRecents() as MissedRecents {
    var missedRecents = Storage.getValue(MissedRecents_valueKey) as MissedRecents | Null;
    if (missedRecents == null) {
        missedRecents = [] as MissedRecents;
    }
    return missedRecents;
}

(:inline, :glance)
function setMissedRecents(missedRecents as MissedRecents | Null) as Void {
    Storage.setValue(MissedRecents_valueKey, missedRecents as Application.PropertyValueType);
    updateUIForMissedRecentsIfInApp();
}

(:inline,:glance,:typecheck([disableGlanceCheck]))
function updateUIForMissedRecentsIfInApp() as Void {
    if (isActiveUiKindApp) {
        updateRecentsMenuItem();
        RecentsManip.updateRecentsView();
    }
}