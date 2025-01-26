import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;

(:background, :typecheck(disableBackgroundCheck))
function handlePing() as Void {
    sendPong();
    switch (activeUiKind) {
        case ACTIVE_UI_NONE: {
            return;
        }
    }
    if (!(WatchUi has :showToast)) {
        return;
    }
    WatchUi.showToast("Ping", null);
}

(:background)
function sendPong() as Void {
    var msg = {
        cmdK => Cmd_pong
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("pong");
    if (debug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}
