using Toybox.Lang;
using Toybox.WatchUi;

(:background, :glance, :typecheck(disableBackgroundCheck))
function setIsHeadsetConnected(isHeadsetConnected as Lang.Boolean) as Void {
    setIsHeadsetConnectedImp(isHeadsetConnected);
    if (getActiveUiKind().equals(ACTIVE_UI_NONE)) {
        return;
    }
    if (!isHeadsetConnected.equals(oldIsHeadsetConnectedImp)) {
        if (isHeadsetConnected) {
            WatchUi.showToast("Headset on", null);
        } else {
            WatchUi.showToast("No headset", null);
        }
    }
}