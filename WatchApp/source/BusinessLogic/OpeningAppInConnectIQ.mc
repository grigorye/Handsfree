import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;

function openAppInConnectIQ() as Void {
    var msg = {
        "cmd" => "openAppInStore",
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("openAppInStore");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}

function toggleSpeaker() as Void {
    var msg = {
        "cmd" => "toggleSpeaker",
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("toggleSpeaker");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}