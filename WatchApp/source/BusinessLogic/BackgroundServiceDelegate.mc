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
            Background.exit("onPhoneAppMessage");
        } else {
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
