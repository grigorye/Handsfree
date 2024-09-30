import Toybox.Lang;
import Toybox.Application;
import Toybox.Lang;

(:inline, :background)
function getLastRecentsCheckDate() as Lang.Number {
    var loadedLastRecentsCheckDate = Storage.getValue("lastRecentsCheckDate") as Lang.Number;
    if (loadedLastRecentsCheckDate == null) {
        loadedLastRecentsCheckDate = 0;
    }
    return loadedLastRecentsCheckDate;
}

(:inline)
function setLastRecentsCheckDate(lastRecentsCheckDate as Lang.Number) as Void {
    if (debug) { _3(L_RECENTS_STORAGE, "setLastRecentsCheckDate", lastRecentsCheckDate); }
    Storage.setValue("lastRecentsCheckDate", lastRecentsCheckDate);
}
