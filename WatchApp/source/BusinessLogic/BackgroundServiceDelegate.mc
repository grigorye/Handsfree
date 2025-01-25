import Toybox.Background;
import Toybox.System;
import Toybox.Communications;
import Toybox.Lang;

(:background)
const L_BACKGROUND_SERVICE as LogComponent = "backgroundService";

module Req {

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        BackgroundSystemStats.saveBackgroundSystemStats();
        ServiceDelegate.initialize();
    }

    function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
        if (debug) { _3(L_BACKGROUND_SERVICE, "activeUiKind", activeUiKind); }
        handleRemoteMessage(msg);
        if (debug) { _3(L_BACKGROUND_SERVICE, "exit", "onPhoneAppMessage"); }
        Background.exit("onPhoneAppMessage");
    }
}

}