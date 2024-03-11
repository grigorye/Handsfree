using Toybox.WatchUi;

class SchedulingCallView extends WatchUi.ProgressBar {
    function initialize(callState as SchedulingCall) {
        var commStatus = callState.commStatus;
        dump("commStatus", commStatus);
        var message = "";
        var progress = null;
        switch (callState.commStatus) {
            case PENDING:
                message = "Pending" + "\n" + callState.phone["number"];
                progress = null;
                break;
            case SUCCEEDED:
                message = "Calling" + "\n" + callState.phone["number"];
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
