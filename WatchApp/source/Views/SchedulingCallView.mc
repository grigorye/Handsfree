using Toybox.WatchUi;
using Toybox.Lang;

class SchedulingCallView extends WatchUi.ProgressBar {
    function initialize(callState as SchedulingCall) {
        var commStatus = callState.commStatus;
        dump("commStatus", commStatus);
        var message = "";
        var progress = null;
        var destination;
        var name = callState.phone["name"] as Lang.String or Null;
        if (name != null && !name.equals("")) {
            destination = name;
        } else {
            destination = callState.phone["number"];
        }
        switch (callState.commStatus) {
            case PENDING:
                message = "Pending" + "\n" + destination;
                progress = null;
                break;
            case SUCCEEDED:
                message = "Calling" + "\n" + destination;
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
