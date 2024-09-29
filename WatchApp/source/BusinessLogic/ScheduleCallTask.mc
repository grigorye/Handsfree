using Toybox.Communications;
using Toybox.Application;
using Toybox.Lang;

const L_SCHEDULE_CALL as LogComponent = "scheduleCall";

class ScheduleCallTask extends Communications.ConnectionListener {
    private var phone as Phone;

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
        } as Lang.Object as Application.PersistableType;
        resetOptimisticCallStates();
        setCallState(new SchedulingCall(phone, PENDING));
        transmitWithRetry("call", msg, self);
    }

    function onComplete() {
        var oldState = getCallState();
        if (!(oldState instanceof SchedulingCall)) {
            // We may already go back, and hence change the call state to Idle.
            if (debug) { _3(L_SCHEDULE_CALL, "onComplete.callStateInvalidated", oldState); }
            return;
        }
        var newState;
        if (AppSettings.isOptimisticCallHandlingEnabled) {
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
        if (!(oldState instanceof SchedulingCall)) {
            // We may already go back, and hence change the call state to Idle.
            if (debug) { _3(L_SCHEDULE_CALL, "onError.callStateInvalidated", oldState); }
            return;
        }
        var newState = oldState.clone();
        newState.commStatus = FAILED;
        setCallState(newState);
    }
}
