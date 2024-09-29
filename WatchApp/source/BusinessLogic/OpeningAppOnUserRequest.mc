import Toybox.Background;

(:background)
const L_OPEN_APP as LogComponent = "openApp";

(:background)
function openAppFailed() as Void {
    if (debug) { _3(L_OPEN_APP, "openAppFailed", "requestingApplicationWake"); }
    Background.requestApplicationWake("Open app");
}
