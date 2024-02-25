using Toybox.Communications;

class CallTaskCommListener extends Communications.ConnectionListener {
    var phone as Phone;

    function initialize(phone as Phone) {
        self.phone = phone;
        Communications.ConnectionListener.initialize();
    }

    function onComplete() {
        var oldState = getCallState() as SchedulingCall;
        if (!(oldState instanceof SchedulingCall)) {
            // We may already go back, and hence change the call state to Idle.
            dumpCallState("CallTask.onComplete.callStateInvalidated", oldState);
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = SUCCEEDED;
        setCallState(newState);
    }

    function onError() {
        var oldState = getCallState() as SchedulingCall;
        if (!(oldState instanceof SchedulingCall)) {
            // We may already go back, and hence change the call state to Idle.
            dumpCallState("CallTask.onError.callStateInvalidated", oldState);
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
