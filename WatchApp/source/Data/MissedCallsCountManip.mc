import Toybox.Lang;
import Toybox.Application;

(:glance, :background)
function getMissedRecents() as Recents {
    var missedRecents = Storage.getValue("missedRecents") as Recents or Null;
    if (missedRecents != null) {
        return missedRecents;
    } else {
        return [] as Recents;
    }
}

(:background)
function setMissedRecents(missedRecents as Recents) as Void {
    Storage.setValue("missedRecents", missedRecents as [Application.PropertyValueType]);
    updateUIForMissedRecentsIfInApp();
}

(:background, :typecheck([disableBackgroundCheck]))
function updateUIForMissedRecentsIfInApp() as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    var mainMenu = viewWithTag("mainMenu") as MainMenu or Null;
    if (mainMenu != null) {
        mainMenu.update();
    }
}