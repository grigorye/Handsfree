using Toybox.WatchUi;

class HangingUpView extends WatchUi.ProgressBar {
    function initialize(callState as HangingUp) {
        var commStatus = callState.commStatus;
        dump("commStatus", commStatus);
        var message = "";
        var progress = null;
        switch (commStatus) {
            case PENDING:
                message = "Hang up\npending...";
                progress = null;
                break;
            case SUCCEEDED:
                message = "Hanging up...";
                progress = 100.0;
                break;
            case FAILED:
                message = "Companion app\ndid not respond";
                progress = 0.0;
                break;
            default:
                System.error("Unknown commStatus");
        }
        WatchUi.ProgressBar.initialize(message, progress);
    }
}
