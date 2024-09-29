import Toybox.Lang;
import Toybox.Application;

(:background)
function getLastRecentsCheckDate() as Lang.Number {
    var loadedLastRecentsCheckDate = Storage.getValue("lastRecentsCheckDate") as Lang.Number;
    if (loadedLastRecentsCheckDate != null) {
        return loadedLastRecentsCheckDate;
    } else {
        return 0;
    }
}

function setLastRecentsCheckDate(lastRecentsCheckDate as Lang.Number) as Void {
    if (debug) { _3(L_RECENTS_STORAGE, "setLastRecentsCheckDate", lastRecentsCheckDate); }
    Storage.setValue("lastRecentsCheckDate", lastRecentsCheckDate);
}
