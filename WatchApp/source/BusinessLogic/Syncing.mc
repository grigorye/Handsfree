using Toybox.Application;
using Toybox.Lang;
using Toybox.Communications;

function requestSync() as Void {
    var msg = {
        "cmd" => "syncMe"
    } as Lang.Object as Application.PersistableType;
    transmitWithRetry("syncMe", msg, new Communications.ConnectionListener());
}

function requestPhones() as Void {
    var msg = {
        "cmd" => "query",
        "args" => {
            "subjects" => ["phones", "recents"]
        }
    } as Lang.Object as Application.PersistableType;
    transmitWithRetry("syncPhones", msg, new Communications.ConnectionListener());
}
