using Toybox.WatchUi;
using Toybox.Lang;

const L_SCHEDULING_CALL_VIEW as LogComponent = new LogComponent("schedulingCallView", false);

class SchedulingCallView extends WatchUi.ProgressBar {
    function initialize(callState as SchedulingCall) {
        var commStatus = callState.commStatus;
        _([L_SCHEDULING_CALL_VIEW, "commStatus", commStatus]);
        var message = "";
        var destination;
        var name = callState.phone["name"] as Lang.String or Null;
        if (name != null && !name.equals("")) {
            destination = name;
        } else {
            destination = callState.phone["number"];
        }
        switch (callState.commStatus) {
            case PENDING:
                message = "|Calling|" + "\n" + destination;
                break;
            case SUCCEEDED:
                message = "Calling" + "\n" + destination;
                break;
            case FAILED:
                message = "Communication\nFailed";
                break;
            default:
                System.error("Unknown commStatus");
        }
        WatchUi.ProgressBar.initialize(message, 0.0);
    }
}
