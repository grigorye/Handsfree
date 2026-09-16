import Toybox.WatchUi;
import Toybox.Lang;

const L_SCHEDULING_CALL_VIEW as LogComponent = "schedulingCallView";

class SchedulingCallView extends WatchUi.ProgressBar {
    function initialize(callState as SchedulingCall) {
        var commStatus = callState.commStatus;
        if (debug) { _3(L_SCHEDULING_CALL_VIEW, "commStatus", commStatus); }
        var message = "" as StringOrResource;
        var destination;
        var name = callState.phone[PhoneField_name] as Lang.String or Null;
        if (name != null && !name.equals("")) {
            destination = name;
        } else {
            destination = callState.phone[PhoneField_number] as Lang.String;
        }
        switch (callState.commStatus) {
            case PENDING:
                var pendingMessage = pendingText(Rez.Strings.callCalling);
                message = Lang.format("$1$\n$2$", [pendingMessage, destination]);
                break;
            case SUCCEEDED:
                message = formatIfResources("$1$\n$2$", [Rez.Strings.callCalling, destination]);
                break;
            case FAILED:
                if (System.getDeviceSettings().phoneConnected) {
                    message = Rez.Strings.callCommunicationFailed;
                } else {
                    message = Rez.Strings.callPhoneNotConnected;
                }
                break;
            default:
                if (errorDebug) {
                    System.error("Unknown commStatus");
                } else {
                    System.error("");
                }
        }
        ProgressBar.initialize(loadIfResource(message), 0.0);
    }
}
