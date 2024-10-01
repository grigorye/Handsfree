import Toybox.WatchUi;

function updateForCheckInStatus() as Void {
    if (getCallState() instanceof Idle) {
        updateStatusMenu();
    }
}
