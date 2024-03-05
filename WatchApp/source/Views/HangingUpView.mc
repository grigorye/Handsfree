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
                message = "Hanging Up...";
                progress = 100.0;
                break;
            case FAILED:
                message = "Hang up failed";
                progress = 0.0;
                break;
            default:
                fatalError("Unknown commStatus");
                break;
        }
        WatchUi.ProgressBar.initialize(message, progress);
    }
}
