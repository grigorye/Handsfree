import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

(:background)
const L_RECENTS_STORAGE as LogComponent = "recents";

module RecentsManip {
(:inline, :background)
const recentsStorageK as Lang.String = "recents.v1";

(:inline, :background)
const recentsVersionStorageK as Lang.String = "recentsVersion.v1";

(:inline, :background)
function setRecentsVersion(version as Version) as Void {
    if (debug) { _3(L_RECENTS_STORAGE, "saveRecentsVersion", version); }
    Storage.setValue(recentsVersionStorageK, version);
}

(:inline, :background)
function getRecentsVersion() as Version {
    var recentsVersion = Storage.getValue(recentsVersionStorageK) as Version;
    return recentsVersion;
}

(:background)
var recentsImp as Recents | Null = null;

(:background)
function getRecents() as Recents {
    if (recentsImp != null) {
        return recentsImp;
    }
    var recents = loadRecents();
    recentsImp = recents;
    return recents;
}

(:inline, :background)
function loadRecents() as Recents {
    var recents = Storage.getValue(recentsStorageK) as Recents or Null;
    if (recents == null) {
        recents = noRecents;
    }
    return recents;
}

(:inline, :background)
function saveRecents(recents as Recents) as Void {
    if (debug) { _3(L_RECENTS_STORAGE, "saveRecents", recents); }
    Storage.setValue(recentsStorageK, recents as [Application.PropertyValueType]);
}

(:background)
function setRecents(recents as Recents) as Void {
    saveRecents(recents);
    recentsImp = recents;
    updateUIForRecentsIfInApp(recents);
    updateMissedRecents();
}

(:background, :typecheck([disableBackgroundCheck]))
function updateUIForRecentsIfInApp(recents as Recents) as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    updateUIForRecents(recents);
}

function updateUIForRecents(recents as Recents) as Void {
    updateRecentsMenuItem();
    updateRecentsView();
    WatchUi.requestUpdate();
}

(:inline)
function updateRecentsView() as Void {
    var recentsView = VT.viewWithTag(V.recents) as RecentsView or Null;
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
