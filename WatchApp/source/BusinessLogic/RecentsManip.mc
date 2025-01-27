import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;

(:glance, :background)
const Recents_valueKey = "recents.v2";
(:glance, :background)
const Recents_versionKey = "recentsVersion.v1";

(:glance, :background)
const Recents_defaultValue = { RecentsField_list => [] as RecentsList } as Recents;

module RecentsManip {

(:background)
function getRecentsList() as RecentsList {
    var recents = X.recents.value();
    var recentsList = recents[RecentsField_list] as RecentsList;
    return recentsList;
}

(:background, :typecheck([disableBackgroundCheck]))
function updateUIForRecentsIfInApp(recents as Recents) as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    updateRecentsMenuItem();
    updateRecentsView();
    WatchUi.requestUpdate();
}

(:inline)
function updateRecentsView() as Void {
    var recentsView = VT.viewWithTag(V_recents) as RecentsScreen.View or Null;
    if (recentsView != null) {
        recentsView.update();
    }
}

function recentsDidOpen() as Void {
    setLastRecentsCheckDate(Time.now().value());
    updateMissedRecents();
    updateRecentsMenuItem();
}

}
