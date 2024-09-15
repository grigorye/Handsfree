using Toybox.Lang;
using Toybox.Application;

(:glance, :background)
function getMissedCallsCount() as Lang.Number {
    var missedCallsCount = Application.Storage.getValue("missedCallsCount") as Lang.Number;
    if (missedCallsCount != null) {
        return missedCallsCount;
    } else {
        return 0;
    }
}

(:background)
function setMissedCallsCount(missedCallsCount as Lang.Number) as Void {
    Application.Storage.setValue("missedCallsCount", missedCallsCount);
    updateUIForMissedCallsCountIfInApp();
}

(:background, :typecheck([disableBackgroundCheck]))
function updateUIForMissedCallsCountIfInApp() as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    var mainMenu = viewWithTag("mainMenu") as MainMenu or Null;
    if (mainMenu != null) {
        mainMenu.update();
    }
}