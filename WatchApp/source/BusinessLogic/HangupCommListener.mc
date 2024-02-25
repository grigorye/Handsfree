using Toybox.Communications;

class HangupCommListener extends Communications.ConnectionListener {
    function initialize() {
        Communications.ConnectionListener.initialize();
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
            dumpCallState("Hangup.onError.callStateInvalidated", oldState);
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
