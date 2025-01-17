import Toybox.Lang;
import Toybox.Application;

(:glance, :background)
const missedRecentsStorageK as Lang.String = "missedRecents";

(:inline, :glance, :background)
function getMissedRecents() as RecentsList {
    var missedRecents = Storage.getValue(missedRecentsStorageK) as RecentsList | Null;
    if (missedRecents == null) {
        missedRecents = [] as RecentsList;
    }
    return missedRecents;
}

(:inline, :background)
function setMissedRecents(missedRecents as RecentsList) as Void {
    Storage.setValue(missedRecentsStorageK, missedRecents as [Application.PropertyValueType]);
    updateUIForMissedRecentsIfInApp();
}

(:inline, :background, :typecheck([disableBackgroundCheck]))
function updateUIForMissedRecentsIfInApp() as Void {
    if (isActiveUiKindApp) {
        updateRecentsMenuItem();
        RecentsManip.updateRecentsView();
    }
}