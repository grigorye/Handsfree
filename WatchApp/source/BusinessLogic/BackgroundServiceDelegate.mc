using Toybox.Background;
using Toybox.System;
using Toybox.Application.Storage;
using Toybox.Communications;

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
        dump("onPhoneAppMessage", msg);
        dump("isRunningInBackground", isRunningInBackground);
        handleRemoteMessage(msg);
        Background.exit("onPhoneAppMessage");
    }
}