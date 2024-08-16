using Toybox.Background;
using Toybox.System;
using Toybox.Communications;
using Toybox.Lang;

(:background)
const L_BACKGROUND_SERVICE as LogComponent = "backgroundService";

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
        _3(L_BACKGROUND_SERVICE, "activeUiKind", activeUiKind);
        handleRemoteMessage(msg);
        _3(L_BACKGROUND_SERVICE, "exit", "onPhoneAppMessage");
        Background.exit("onPhoneAppMessage");
    }
}
