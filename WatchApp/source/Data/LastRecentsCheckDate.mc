import Toybox.Lang;
import Toybox.Application;
import Toybox.Lang;

(:glance)
const L_RECENTS_STORAGE as LogComponent = "recents";

(:glance)
const Storage_lastRecentsCheckDate = "D.1";

(:inline, :glance)
function getLastRecentsCheckDate() as Lang.Number {
    var loadedLastRecentsCheckDate = Storage.getValue(Storage_lastRecentsCheckDate) as Lang.Number or Null;
    if (loadedLastRecentsCheckDate == null) {
        loadedLastRecentsCheckDate = 0;
    }
    return loadedLastRecentsCheckDate;
}

(:inline)
function setLastRecentsCheckDate(lastRecentsCheckDate as Lang.Number) as Void {
    if (debug) { _3(L_RECENTS_STORAGE, "setLastRecentsCheckDate", lastRecentsCheckDate); }
    Storage.setValue(Storage_lastRecentsCheckDate, lastRecentsCheckDate);
}
