import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

(:background)
const L_RECENTS_STORAGE as LogComponent = "recents";

(:inline, :background)
function setRecentsVersion(version as Version) as Void {
    if (debug) { _3(L_RECENTS_STORAGE, "saveRecentsVersion", version); }
    Storage.setValue("recentsVersion.v1", version);
}

(:inline, :background)
function getRecentsVersion() as Version {
    var recentsVersion = Storage.getValue("recentsVersion.v1") as Version;
    return recentsVersion;
}

(:inline, :background)
function getRecents() as Recents {
    var recents = Storage.getValue("recents.v1") as Recents or Null;
    if (recents == null) {
        recents = [] as Recents;
    }
    return recents;
}

(:inline, :background)
function saveRecents(recents as Recents) as Void {
    if (debug) { _3(L_RECENTS_STORAGE, "saveRecents", recents); }
    Storage.setValue("recents.v1", recents as [Application.PropertyValueType]);
}

(:background)
function setRecents(recents as Recents) as Void {
    saveRecents(recents);
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
    updateMainMenu();
    updateRecentsView();
    WatchUi.requestUpdate();
}

(:inline)
function updateRecentsView() as Void {
    var recentsView = viewWithTag("recents") as RecentsView or Null;
    if (recentsView != null) {
        recentsView.update();
    }
}

function updateMainMenu() as Void {
    var mainMenu = viewWithTag("mainMenu") as MainMenu or Null;
    if (mainMenu != null) {
        mainMenu.update();
    }
}

function recentsDidOpen() as Void {
    setLastRecentsCheckDate(Time.now().value());
    updateMissedRecents();
    updateMainMenu();
}
