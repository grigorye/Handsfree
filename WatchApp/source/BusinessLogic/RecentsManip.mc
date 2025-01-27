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

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIForRecentsIfInApp() as Void {
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
