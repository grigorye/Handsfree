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
        dump("callAction.outMsg", msg);
        setCallState(new CallActing(phone, PENDING));
        transmitWithRetry(cmd, msg, self);
    }

    function onComplete() {
        var oldState = getCallState() as CallActing;
        if (!(oldState instanceof CallActing)) {
            // We may already go back, and hence change the call state to Idle.
            dumpCallState("callAction.onComplete.callStateInvalidated", oldState);
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
            dumpCallState("callAction.onError.callStateInvalidated", oldState);
            return;
        }
        dump("callAction.onError", true);
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
