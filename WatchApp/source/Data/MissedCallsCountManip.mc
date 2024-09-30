import Toybox.Lang;
import Toybox.Application;

(:inline, :glance, :background)
function getMissedRecents() as Recents {
    var missedRecents = Storage.getValue("missedRecents") as Recents or Null;
    if (missedRecents == null) {
        missedRecents = [] as Recents;
    }
    return missedRecents;
}

(:inline, :background)
function setMissedRecents(missedRecents as Recents) as Void {
    Storage.setValue("missedRecents", missedRecents as [Application.PropertyValueType]);
    updateUIForMissedRecentsIfInApp();
}

(:inline, :background, :typecheck([disableBackgroundCheck]))
function updateUIForMissedRecentsIfInApp() as Void {
    if (isActiveUiKindApp) {
        var mainMenu = viewWithTag("mainMenu") as MainMenu or Null;
        if (mainMenu != null) {
            mainMenu.update();
        }
    }
}