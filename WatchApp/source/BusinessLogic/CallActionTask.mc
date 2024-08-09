using Toybox.Communications;

class CallActionTask extends Communications.ConnectionListener {
    var phone as Phone;
    var action as CallInProgressAction;

    function initialize(phone as Phone, action as CallInProgressAction) {
        ConnectionListener.initialize();
        self.phone = phone;
        self.action = action;
    }

    function launch() as Void {
        dump("callAction.launch", true);

        var cmd;
        var state;
        switch (action) {
            case CALL_IN_PROGRESS_ACTION_ACCEPT: {
                cmd = "accept";
                state = new Accepting(phone, PENDING);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_HANGUP: {
                cmd = "hangup";
                state = new HangingUp(phone, PENDING);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_REJECT: {
                cmd = "hangup";
                state = new Declining(phone, PENDING);
                break;
            }
            default:
                System.error("unknownAction: " + action);
        }
        var msg = {
            "cmd" => cmd
        };
        dump("callAction.outMsg", msg);
        setCallState(state as CallState);
        transmitWithRetry(cmd, msg, self);
    }

    function onComplete() {
        var oldState = getCallState() as CallActing;
        if (!(oldState instanceof CallActing)) {
            // We may already go back, and hence change the call state to Idle.
            dump("callAction.onComplete.callStateInvalidated", oldState);
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = SUCCEEDED;
        setCallState(newState);
    }

    function onError() {
        var oldState = getCallState() as CallActing;
        if (!(oldState instanceof CallActing)) {
            // We may already go back, and hence change the call state to Idle.
            dump("callAction.onError.callStateInvalidated", oldState);
            return;
        }
        dump("callAction.onError", true);
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
