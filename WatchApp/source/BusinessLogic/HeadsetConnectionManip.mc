using Toybox.Lang;
using Toybox.WatchUi;

(:background, :typecheck(disableBackgroundCheck))
function setIsHeadsetConnected(isHeadsetConnected as Lang.Boolean) as Void {
    setIsHeadsetConnectedImp(isHeadsetConnected);
    switch (activeUiKind) {
        case ACTIVE_UI_NONE: {
            return;
        }
        case ACTIVE_UI_GLANCE: {
            WatchUi.requestUpdate();
            return;
        }
        case ACTIVE_UI_APP: {
            if (!isHeadsetConnected.equals(oldIsHeadsetConnectedImp)) {
                if (WatchUi has :showToast) {
                    if (isHeadsetConnected) {
                        WatchUi.showToast("Headset on", null);
                    } else {
                        WatchUi.showToast("No headset", null);
                    }
                }
            }
            return;
        }
    }
}