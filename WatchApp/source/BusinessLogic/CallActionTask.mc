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
                cmd = Cmd.accept;
                state = new Accepting(phone, PENDING);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_HANGUP: {
                cmd = Cmd.hangup;
                state = new HangingUp(phone, PENDING);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_REJECT: {
                cmd = Cmd.hangup;
                state = new Declining(phone, PENDING);
                break;
            }
            default: {
                cmd = "";
                System.error("unknownAction: " + action);
            }
        }
        var msg = {
            cmdK => cmd
        } as Lang.Object as Application.PersistableType;
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