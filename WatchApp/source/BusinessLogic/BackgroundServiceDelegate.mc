using Toybox.Background;
using Toybox.System;
using Toybox.Communications;
using Toybox.Lang;

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
        dump("onPhoneAppMessage", msg);
        dump("activeUiKind", getActiveUiKind());
        handleRemoteMessage(msg);
        if (isBackgroundAppUpdateEnabled()) {
            dump("backgroundExit", "onPhoneAppMessage");
            Background.exit("onPhoneAppMessage");
        } else {
            dump("backgroundExit", null);
            Background.exit(null);
        }
    }
}

(:background, :glance)
function isBackgroundAppUpdateEnabled() as Lang.Boolean {
    if (isBuiltAsWidget() && !isInWidgetMode()) {
        return false;
    }
    return true;
}
