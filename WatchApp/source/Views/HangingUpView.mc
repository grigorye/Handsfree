using Toybox.WatchUi;

class HangingUpView extends WatchUi.ProgressBar {
    function initialize(callState as HangingUp) {
        var commStatus = callState.commStatus;
        var phone = callState.phone;
        dump("commStatus", commStatus);
        var message = "";
        switch (commStatus) {
            case PENDING:
                if (isIncomingCallPhone(phone)) {
                    message = "Accept\npending...";
                } else {
                    message = "Hang up\npending...";
                }
                break;
            case SUCCEEDED:
                if (isIncomingCallPhone(phone)) {
                    message = "Accepting...";
                } else {
                    message = "Hanging up...";
                }
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
