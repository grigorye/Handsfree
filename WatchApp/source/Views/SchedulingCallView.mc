import Toybox.WatchUi;
import Toybox.Lang;

const L_SCHEDULING_CALL_VIEW as LogComponent = "schedulingCallView";

class SchedulingCallView extends WatchUi.ProgressBar {
    function initialize(callState as SchedulingCall) {
        var commStatus = callState.commStatus;
        if (debug) { _3(L_SCHEDULING_CALL_VIEW, "commStatus", commStatus); }
        var message = "";
        var destination;
        var name = callState.phone[PhoneField_name] as Lang.String or Null;
        if (name != null && !name.equals("")) {
            destination = name;
        } else {
            destination = callState.phone[PhoneField_number];
        }
        switch (callState.commStatus) {
            case PENDING:
                message = "|Calling|" + "\n" + destination;
                break;
            case SUCCEEDED:
                message = "Calling" + "\n" + destination;
                break;
            case FAILED:
                if (System.getDeviceSettings().phoneConnected) {
                    message = "Communication\nFailed";
                } else {
                    message = "Phone\nNot Connected";
                }
                break;
            default:
                if (errorDebug) {
                    System.error("Unknown commStatus");
                } else {
                    System.error("");
                }
        }
        ProgressBar.initialize(message, 0.0);
    }
}
