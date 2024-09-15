using Toybox.Lang;
using Toybox.Application;

(:background)
function getLastRecentsCheckDate() as Lang.Number {
    var loadedLastRecentsCheckDate = Application.Storage.getValue("lastRecentsCheckDate") as Lang.Number;
    if (loadedLastRecentsCheckDate != null) {
        return loadedLastRecentsCheckDate;
    } else {
        return 0;
    }
}

function setLastRecentsCheckDate(lastRecentsCheckDate as Lang.Number) as Void {
    _3(L_STORAGE, "setLastRecentsCheckDate", lastRecentsCheckDate);
    Application.Storage.setValue("lastRecentsCheckDate", lastRecentsCheckDate);
}
