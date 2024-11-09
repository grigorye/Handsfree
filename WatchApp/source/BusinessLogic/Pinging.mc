import Toybox.WatchUi;

(:background, :typecheck(disableBackgroundCheck))
function handlePing() as Void {
    switch (activeUiKind) {
        case ACTIVE_UI_NONE: {
            return;
        }
    }
    if (!(WatchUi has :showToast)) {
        return;
    }
    WatchUi.showToast("Ping", null);
}