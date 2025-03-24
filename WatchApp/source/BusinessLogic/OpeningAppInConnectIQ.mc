import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;

(:settings)
module Req {

function openAppInConnectIQ() as Void {
    var msg = {
        cmdK => Cmd_openAppInStore,
    };
    transmitWithoutRetry("openAppInStore", msg);
}

}

(:companion)
module Req {

function installCompanionApp() as Void {
    Communications.openWebPage(
        "https://grigorye.github.io/handsfree/Installation",
        {},
        null
    );
    showFeedback("Sent notification\nto your phone");
}

}