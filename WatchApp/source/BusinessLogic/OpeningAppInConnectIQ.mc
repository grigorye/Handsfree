import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;

function openAppInConnectIQ() as Void {
    var msg = {
        cmdK => Cmd_openAppInStore,
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("openAppInStore");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}

function installCompanionApp() as Void {
    Communications.openWebPage(
        "https://grigorye.github.io/handsfree/Installation",
        {},
        null
    );
    showFeedback("Sent notification\nto your phone");
}
