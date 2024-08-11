using Toybox.Background;
using Toybox.System;
using Toybox.Communications;
using Toybox.Lang;

(:background)
const L_BACKGROUND_SERVICE as LogComponent = new LogComponent("backgroundService", true);

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
        _([L_BACKGROUND_SERVICE, "activeUiKind", getActiveUiKind()]);
        handleRemoteMessage(msg);
        if (isBackgroundAppUpdateEnabled()) {
            _([L_BACKGROUND_SERVICE, "exit", "onPhoneAppMessage"]);
            Background.exit("onPhoneAppMessage");
        } else {
            _([L_BACKGROUND_SERVICE, "exit", null]);
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
