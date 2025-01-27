import Toybox.Lang;
import Toybox.Application;

(:glance, :background)
const MissedRecents_valueKey = "missedRecents.v1";

(:inline, :glance, :background)
typedef MissedRecents as Lang.Array<Lang.Number>;

(:inline, :glance, :background)
function getMissedRecents() as MissedRecents {
    var missedRecents = Storage.getValue(MissedRecents_valueKey) as MissedRecents | Null;
    if (missedRecents == null) {
        missedRecents = [] as MissedRecents;
    }
    return missedRecents;
}

(:inline, :background)
function setMissedRecents(missedRecents as MissedRecents | Null) as Void {
    Storage.setValue(MissedRecents_valueKey, missedRecents as Application.PropertyValueType);
    updateUIForMissedRecentsIfInApp();
}

(:inline, :background, :typecheck([disableBackgroundCheck]))
function updateUIForMissedRecentsIfInApp() as Void {
    if (isActiveUiKindApp) {
        updateRecentsMenuItem();
        RecentsManip.updateRecentsView();
    }
}