using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Time;

(:background)
function setRecentsVersion(version as Version) as Void {
    _3(L_STORAGE, "saveRecentsVersion", version);
    Application.Storage.setValue("recentsVersion.v1", version);
}

(:background)
function getRecentsVersion() as Version {
    var recentsVersion = Application.Storage.getValue("recentsVersion.v1") as Version;
    return recentsVersion;
}

(:background)
function getRecents() as Recents {
    var recents = Application.Storage.getValue("recents.v1") as Recents or Null;
    if (recents != null) {
        return recents;
    } else {
        return [] as Recents;
    }
}

(:background)
function saveRecents(recents as Recents) as Void {
    _3(L_STORAGE, "saveRecents", recents);
    Application.Storage.setValue("recents.v1", recents as [Application.PropertyValueType]);
}

(:background)
function setRecents(recents as Recents) as Void {
    saveRecents(recents);
    updateUIForRecentsIfInApp(recents);
    updateMissedCallsCount();
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
}

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
    updateMissedCallsCount();
    updateMainMenu();
}
