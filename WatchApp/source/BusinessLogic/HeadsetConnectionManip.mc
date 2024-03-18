using Toybox.Lang;
using Toybox.WatchUi;

(:background, :glance, :typecheck(disableBackgroundCheck))
function setIsHeadsetConnected(isHeadsetConnected as Lang.Boolean) as Void {
    setIsHeadsetConnectedImp(isHeadsetConnected);
    switch (getActiveUiKind()) {
        case ACTIVE_UI_NONE: {
            return;
        }
        case ACTIVE_UI_GLANCE: {
            WatchUi.requestUpdate();
            return;
        }
        case ACTIVE_UI_APP: {
            if (!isHeadsetConnected.equals(oldIsHeadsetConnectedImp)) {
                if (isHeadsetConnected) {
                    WatchUi.showToast("Headset on", null);
                } else {
                    WatchUi.showToast("No headset", null);
                }
            }
            return;
        }
    }
}