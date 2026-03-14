import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

const L_SCHEDULE_CALL as LogComponent = "scheduleCall";

module Req {

class ScheduleCallTask extends Communications.ConnectionListener {
    private var phone as Phone;

    function initialize(phone as Phone) {
        ConnectionListener.initialize();
        self.phone = phone;
    }

    function launch() as Void {
        if (!preflightAllReadiness()) {
            return;
        }
        var msg = {
            cmdK => Cmd_call,
            CallArgsK_number => getPhoneNumber(phone)
        };
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

(:noReadiness)
function preflightAllReadiness() as Lang.Boolean {
    return true;
}

(:readiness)
function preflightAllReadiness() as Lang.Boolean {
    if (!preflightReadiness(ReadinessField_essentials, "Call control")) {
        return false;
    }
    if (!preflightReadiness(ReadinessField_outgoingCalls, "Outgoing calls")) {
        return false;
    }
    return true;
}

(:readiness)
function preflightReadiness(field as Lang.String, title as Lang.String) as Lang.Boolean {
    var readiness = ReadinessInfoManip.readiness(field);
    if (readiness.equals(ReadinessValue_ready)) {
        return true;
    }
    if (debug) { _3(L_SCHEDULE_CALL, "notReady", field + ":" + readiness); }
    var format;
    switch (readiness) {
        case ReadinessValue_disabled: {
            format = "$1$\nnot enabled";
            break;
        }
        case ReadinessValue_notPermitted: {
            format = "$1$\nnot permitted";
            break;
        }
        case ReadinessValue_notReady: {
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

}