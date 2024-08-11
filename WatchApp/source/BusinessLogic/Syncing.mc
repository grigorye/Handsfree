using Toybox.Communications;
using Toybox.Application;
using Toybox.Lang;

function requestSync() as Void {
    var msg = {
        "cmd" => "syncMe"
    } as Lang.Object as Application.PersistableType;
    transmitWithRetry("syncMe", msg, new SyncCommListener());
}

function requestPhones() as Void {
    var msg = {
        "cmd" => "syncPhones"
    } as Lang.Object as Application.PersistableType;
    transmitWithRetry("syncPhones", msg, new SyncCommListener());
}
