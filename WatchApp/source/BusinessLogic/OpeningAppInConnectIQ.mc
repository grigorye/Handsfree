import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;
import Toybox.System;

(:settings)
module Req {

function openAppInConnectIQ() as Void {
    var msg = {
        cmdK => Cmd_openAppInStore,
    };
    transmitWithoutRetry("openAppInStore", msg);
}

}

(:background, :noCompanion)
const companionInfoEnabled = false;

(:background, :companion)
const companionInfoEnabled = true;

module Req {

(:noCompanion)
function installCompanionApp() as Void {
    if (errorDebug) {
        System.error("Employ companionInfoEnabled check on caller side");
    }
}

(:companion)
function installCompanionApp() as Void {
    Communications.openWebPage(
        "https://grigorye.github.io/handsfree/Installation",
        {},
        null
    );
    showFeedback("Sent notification\nto your phone");
}

}