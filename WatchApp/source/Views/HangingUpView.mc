using Toybox.WatchUi;

class HangingUpView extends WatchUi.ProgressBar {
    function initialize(callState as HangingUp) {
        var commStatus = callState.commStatus;
        dump("commStatus", commStatus);
        var message = "";
        switch (commStatus) {
            case PENDING:
                message = "Hang up\npending...";
                break;
            case SUCCEEDED:
                message = "Hanging up...";
                break;
            case FAILED:
                message = "Companion app\ndid not respond";
                break;
            default:
                System.error("Unknown commStatus");
        }
        WatchUi.ProgressBar.initialize(message, 0.0);
    }
}
