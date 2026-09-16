import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

const L_CALL_ACTING_DATA as LogComponent = "callActing";

class CallActingView extends WatchUi.ProgressBar {
    function initialize(callState as CallActing) {
        var commStatus = callState.commStatus;
        if (debug) { _3(L_CALL_ACTING_DATA, "commStatus", commStatus); }
        var source = displayTextForPhone(callState.phone);
        var message = "" as StringOrResource;
        switch (commStatus) {
            case PENDING:
                switch (callState) {
                    case instanceof Accepting: {
                        var pendingMessage = pendingText(Rez.Strings.callAnswering);
                        message = Lang.format("$1$\n$2$", [pendingMessage, source]);
                        break;
                    }
                    case instanceof HangingUp: {
                        var pendingMessage = pendingText(Rez.Strings.callHangingUp);
                        message = Lang.format("$1$\n$2$", [pendingMessage, source]);
                        break;
                    }
                    case instanceof Declining: {
                        var pendingMessage = pendingText(Rez.Strings.callDeclining);
                        message = Lang.format("$1$\n$2$", [pendingMessage, source]);
                        break;
                    }
                    default: {
                        message = "";
                        if (errorDebug) {
                            System.error("unexpectedCallState: " + callState);
                        } else {
                            System.error("");
                        }
                    }
                }
                break;
            case SUCCEEDED:
                switch (callState) {
                    case instanceof Accepting: {
                        message = formatIfResources("$1$\n$2$", [Rez.Strings.callAnswering, source]);
                        break;
                    }
                    case instanceof HangingUp: {
                        message = formatIfResources("$1$\n$2$", [Rez.Strings.callHangingUp, source]);
                        break;
                    }
                    case instanceof Declining: {
                        message = formatIfResources("$1$\n$2$", [Rez.Strings.callDeclining, source]);
                        break;
                    }
                    default: {
                        message = "";
                        if (errorDebug) {
                            System.error("unexpectedCallState: " + callState);
                        } else {
                            System.error("");
                        }
                    }
                }
                break;
            case FAILED:
                var deviceSettings = System.getDeviceSettings();
                if (deviceSettings.phoneConnected) {
                    message = Rez.Strings.callCommunicationFailed;
                } else {
                    message = Rez.Strings.callNoConnection;
                }
                break;
            default:
                message = "";
                if (errorDebug) {
                    System.error("Unknown commStatus");
                } else {
                    System.error("");
                }
        }
        ProgressBar.initialize(loadIfResource(message), 0.0);
    }
}
