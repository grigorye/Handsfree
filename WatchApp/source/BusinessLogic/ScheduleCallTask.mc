import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

const L_SCHEDULE_CALL as LogComponent = "scheduleCall";

class ScheduleCallTask extends Communications.ConnectionListener {
    private var phone as Phone;

    function initialize(phone as Phone) {
        ConnectionListener.initialize();
        self.phone = phone;
    }

    function launch() as Void {
        if (!preflightScheduledCall()) {
            return;
        }
        var msg = {
            cmdK => Cmd.call,
            argsK => {
                CallArgsK.number => getPhoneNumber(phone)
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

function preflightScheduledCall() as Lang.Boolean {
    var outgoingCallsReadiness = ReadinessInfoManip.readiness(ReadinessField.outgoingCalls);
    if (outgoingCallsReadiness.equals(ReadinessValue.ready)) {
        return true;
    }
    if (debug) { _3(L_SCHEDULE_CALL, "outgoingCallsNotReady", outgoingCallsReadiness); }
    switch (outgoingCallsReadiness) {
        case ReadinessValue.disabled: {
            showFeedback("Outgoing calls\nare disabled");
            break;
        }
        case ReadinessValue.notPermitted: {
            showFeedback("Outgoing calls\nlack permissions");
            break;
        }
        case ReadinessValue.notReady: {
            showFeedback("Outgoing calls\nnot ready");
            break;
        }
    }
    return false;
}