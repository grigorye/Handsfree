using Toybox.Communications;

class ScheduleCallTask extends Communications.ConnectionListener {
    var phone as Phone;

    function initialize(phone as Phone) {
        ConnectionListener.initialize();
        self.phone = phone;
    }

    function launch() as Void {
        var msg = {
            "cmd" => "call",
            "args" => {
                "number" => getPhoneNumber(phone)
            }
        };
        setCallState(new SchedulingCall(phone, PENDING));
        transmitWithRetry("scheduleCall", msg, self);
    }

    function onComplete() {
        var oldState = getCallState() as SchedulingCall;
        if (!(oldState instanceof SchedulingCall)) {
            // We may already go back, and hence change the call state to Idle.
            dump("scheduleCall.onComplete.callStateInvalidated", oldState);
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
            dump("scheduleCall.onError.callStateInvalidated", oldState);
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
