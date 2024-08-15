using Toybox.Background;

(:background)
const L_OPEN_APP as LogComponent = "openApp";

(:background)
function openAppFailed() as Void {
    _3(L_OPEN_APP, "openAppFailed", "requestingApplicationWake");
    Background.requestApplicationWake("Open app");
}
