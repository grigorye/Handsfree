import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

const L_CALL_ACTION as LogComponent = "callAction";

module Req {

class CallActionTask extends Communications.ConnectionListener {
    private var phone as Phone;
    private var action as CallInProgressAction;

    function initialize(phone as Phone, action as CallInProgressAction) {
        ConnectionListener.initialize();
        self.phone = phone;
        self.action = action;
    }

    function launch() as Void {
        if (debug) { _3(L_CALL_ACTION, "launch", true); }

        var cmd;
        var state;
        switch (action) {
            case CALL_IN_PROGRESS_ACTION_ACCEPT: {
                cmd = Cmd_accept;
                state = new Accepting(phone, PENDING);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_HANGUP: {
                cmd = Cmd_hangup;
                state = new HangingUp(phone, PENDING);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_REJECT: {
                cmd = Cmd_hangup;
                state = new Declining(phone, PENDING);
                break;
            }
            default: {
                cmd = "";
                if (testDebug) {
                    System.error("unknownAction: " + action);
                } else {
                    System.error("");
                }
            }
        }
        var msg = {
            cmdK => cmd
        };
        setCallState(state as CallState);
        transmitWithRetry(cmd, msg, self);
    }

    function onComplete() {
        var oldState = getCallState();
        if (!(oldState instanceof CallActing)) {
            // We may already go back, and hence change the call state to Idle.
            if (debug) { _3(L_CALL_ACTION, "onComplete.callStateInvalidated", oldState); }
            return;
        }
        var newState;
        if (AppSettings.isOptimisticCallHandlingEnabled()) {
            newState = oldState.wouldBeNextState();
            trackOptimisticCallState(newState);
        } else {
            newState = oldState.clone();
            newState.commStatus = SUCCEEDED;
        }
        setCallState(newState);
    }

    function onError() {
        var oldState = getCallState();
        if (!(oldState instanceof CallActing)) {
            // We may already go back, and hence change the call state to Idle.
            if (debug) { _3(L_CALL_ACTION, "onError.callStateInvalidated", oldState); }
            return;
        }
        if (debug) { _2(L_CALL_ACTION, "onError"); }
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}

}