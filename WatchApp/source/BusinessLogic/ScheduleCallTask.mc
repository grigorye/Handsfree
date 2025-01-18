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
        if (!preflightReadiness(ReadinessField.essentials, "Call control")) {
            return;
        }
        if (!preflightReadiness(ReadinessField.outgoingCalls, "Outgoing calls")) {
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

function preflightReadiness(field as Lang.String, title as Lang.String) as Lang.Boolean {
    var readiness = ReadinessInfoManip.readiness(field);
    if (readiness.equals(ReadinessValue.ready)) {
        return true;
    }
    if (debug) { _3(L_SCHEDULE_CALL, "notReady", field + ":" + readiness); }
    var format;
    switch (readiness) {
        case ReadinessValue.disabled: {
            format = "$1$\nnot enabled";
            break;
        }
        case ReadinessValue.notPermitted: {
            format = "$1$\nnot permitted";
            break;
        }
        case ReadinessValue.notReady: {
            format = "$1$\nnot ready";
            break;
        }
        default: {
            format = "$1$\nnot ready?";
            break;
        }
    }
    var message = Lang.format(format, [title]);
    showFeedback(message);
    return false;
}
