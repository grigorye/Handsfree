using Toybox.Communications;

class HangupOrAcceptCallTask extends Communications.ConnectionListener {
    var phone as Phone;

    function initialize(phone as Phone) {
        ConnectionListener.initialize();
        self.phone = phone;
    }

    function launch() as Void {
        dump("hangup.launch", true);
        var cmd;
        if (isIncomingCallPhone(phone)) {
            cmd = "accept";
        } else {
            cmd = "hangup";
        }
        var msg = {
            "cmd" => cmd
        };
        dump("hangup.outMsg", msg);
        setCallState(new HangingUp(phone, PENDING));
        transmitWithRetry("hangup", msg, self);
    }

    function onComplete() {
        var oldState = getCallState() as HangingUp;
        if (!(oldState instanceof HangingUp)) {
            // We may already go back, and hence change the call state to Idle.
            dumpCallState("Hangup.onComplete.callStateInvalidated", oldState);
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
            dumpCallState("hangup.onError.callStateInvalidated", oldState);
            return;
        }
        dump("hangup.onError", true);
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
