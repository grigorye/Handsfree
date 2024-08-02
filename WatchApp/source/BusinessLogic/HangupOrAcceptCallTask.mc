using Toybox.Communications;

class CallActionTask extends Communications.ConnectionListener {
    var phone as Phone;

    function initialize(phone as Phone) {
        ConnectionListener.initialize();
        self.phone = phone;
    }

    function launch() as Void {
        dump("callAction.launch", true);
        var cmd;
        if (isIncomingCallPhone(phone)) {
            cmd = "accept";
        } else {
            cmd = "hangup";
        }
        var msg = {
            "cmd" => cmd
        };
        setCallState(new HangingUp(phone, PENDING));
        transmitWithRetry("hangup", msg, self);
        dump("callAction.outMsg", msg);
    }

    function onComplete() {
        var oldState = getCallState() as HangingUp;
        if (!(oldState instanceof HangingUp)) {
            // We may already go back, and hence change the call state to Idle.
            dumpCallState("callAction.onComplete.callStateInvalidated", oldState);
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = SUCCEEDED;
        setCallState(newState);
    }

    function onError() {
        var oldState = getCallState() as HangingUp;
        if (!(oldState instanceof HangingUp)) {
            // We may already go back, and hence change the call state to Idle.
            dumpCallState("callAction.onError.callStateInvalidated", oldState);
            return;
        }
        dump("callAction.onError", true);
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
