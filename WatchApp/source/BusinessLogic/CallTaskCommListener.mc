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
            crash();
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = SUCCEEDED;
        setCallState(newState);
    }

    function onError() {
        var oldState = getCallState() as SchedulingCall;
        if (!(oldState instanceof SchedulingCall)) {
            crash();
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
