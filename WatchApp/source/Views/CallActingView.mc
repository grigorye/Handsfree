import Toybox.WatchUi;
import Toybox.System;

const L_CALL_ACTING_DATA as LogComponent = "callActing";

class CallActingView extends WatchUi.ProgressBar {
    function initialize(callState as CallActing) {
        var commStatus = callState.commStatus;
        if (debug) { _3(L_CALL_ACTING_DATA, "commStatus", commStatus); }
        var source = displayTextForPhone(callState.phone);
        var message;
        switch (commStatus) {
            case PENDING:
                switch (callState) {
                    case instanceof Accepting: {
                        message = "|Answering|" + "\n" + source;
                        break;
                    }
                    case instanceof HangingUp: {
                        message = "|Hanging Up|" + "\n" + source;
                        break;
                    }
                    case instanceof Declining: {
                        message = "|Declining|" + "\n" + source;
                        break;
                    }
                    default: {
                        message = "";
                        System.error("unexpectedCallState: " + callState);
                    }
                }
                break;
            case SUCCEEDED:
                switch (callState) {
                    case instanceof Accepting: {
                        message = "Answering" + "\n" + source;
                        break;
                    }
                    case instanceof HangingUp: {
                        message = "Hanging Up" + "\n" + source;
                        break;
                    }
                    case instanceof Declining: {
                        message = "Declining" + "\n" + source;
                        break;
                    }
                    default: {
                        message = "";
                        System.error("unexpectedCallState: " + callState);
                    }
                }
                break;
            case FAILED:
                var deviceSettings = System.getDeviceSettings();
                if (deviceSettings.phoneConnected) {
                    message = "Communication\nFailed";
                } else {
                    message = "No Connection";
                }
                break;
            default:
                message = "";
                System.error("Unknown commStatus");
        }
        ProgressBar.initialize(message, 0.0);
    }
}
