import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;

module Req {

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
    };
    transmitWithoutRetry("pong", msg);
}

}
