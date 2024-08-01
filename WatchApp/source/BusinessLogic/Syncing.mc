using Toybox.Communications;

function requestSync() as Void {
    var msg = {
        "cmd" => "syncMe"
    };
    dump("outMsg", msg);
    transmitWithRetry("syncMe", msg, new SyncCommListener());
}

function requestPhones() as Void {
    var msg = {
        "cmd" => "syncPhones"
    };
    dump("outMsg", msg);
    transmitWithRetry("syncPhones", msg, new SyncCommListener());
}
