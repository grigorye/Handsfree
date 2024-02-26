using Toybox.WatchUi;

class SchedulingCallView extends WatchUi.ProgressBar {
    function initialize(callState as SchedulingCall) {
        var commStatus = callState.commStatus;
        dump("commStatus", commStatus);
        var message = "";
        var progress = null;
        switch (callState.commStatus) {
            case PENDING:
                message = "Calling" + "\n" + callState.phone["number"];
                progress = null;
                break;
            case SUCCEEDED:
                message = "Awaiting" + "\n" + callState.phone["number"];
                progress = 100.0;
                break;
            case FAILED:
                message = "Communication failed";
                progress = 0.0;
                break;
            default:
                fatalError("Unknown commStatus");
                break;
        }
        WatchUi.ProgressBar.initialize(message, progress);
    }
}
