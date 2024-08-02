using Toybox.WatchUi;

class CallActingView extends WatchUi.ProgressBar {
    function initialize(callState as CallActing) {
        var commStatus = callState.commStatus;
        dump("commStatus", commStatus);
        var message = "";
        switch (commStatus) {
            case PENDING:
                switch (callState) {
                    case instanceof Accepting: {
                        message = "Accept\npending";
                        break;
                    }
                    case instanceof HangingUp: {
                        message = "Hang up\npending";
                        break;
                    }
                    case instanceof Declining: {
                        message = "Decline\npending";
                        break;
                    }
                    default: {
                        System.error("unexpectedCallState: " + callState.dumpRep());
                    }
                }
                break;
            case SUCCEEDED:
                switch (callState) {
                    case instanceof Accepting: {
                        message = "Accepting";
                        break;
                    }
                    case instanceof HangingUp: {
                        message = "Hanging up";
                        break;
                    }
                    case instanceof Declining: {
                        message = "Declining";
                        break;
                    }
                    default: {
                        System.error("unexpectedCallState: " + callState.dumpRep());
                    }
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
