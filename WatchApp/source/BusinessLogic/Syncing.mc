using Toybox.Communications;

function requestSync() as Void {
    var msg = {
        "cmd" => "syncMe"
    };
    dump("outMsg", msg);
    Communications.transmit(msg, null, new SyncCommListener());
}

function requestPhones() as Void {
    var msg = {
        "cmd" => "syncPhones"
    };
    dump("outMsg", msg);
    Communications.transmit(msg, null, new SyncCommListener());
}
