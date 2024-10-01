import Toybox.WatchUi;

(:noLowMemory)
function updateForCheckInStatus() as Void {
    if (getCallState() instanceof Idle) {
        updateStatusMenu();
    }
}
