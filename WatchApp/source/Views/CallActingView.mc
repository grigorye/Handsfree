using Toybox.WatchUi;

const L_CALL_ACTING_DATA as LogComponent = new LogComponent("callActing", false);

class CallActingView extends WatchUi.ProgressBar {
    function initialize(callState as CallActing) {
        var commStatus = callState.commStatus;
        _([L_CALL_ACTING_DATA, "commStatus", commStatus]);
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
                message = "Communication\nFailed";
                break;
            default:
                message = "";
                System.error("Unknown commStatus");
        }
        WatchUi.ProgressBar.initialize(message, 0.0);
    }
}
