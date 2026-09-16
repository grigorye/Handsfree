import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

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
    if (!preflightReadiness(ReadinessField_essentials, Rez.Strings.readinessCallControl)) {
        return false;
    }
    if (!preflightReadiness(ReadinessField_outgoingCalls, Rez.Strings.readinessOutgoingCalls)) {
        return false;
    }
    return true;
}

(:readiness)
function preflightReadiness(field as Lang.String, title as StringOrResource) as Lang.Boolean {
    var readiness = ReadinessInfoManip.readiness(field);
    if (readiness.equals(ReadinessValue_ready)) {
        return true;
    }
    if (debug) { _3(L_SCHEDULE_CALL, "notReady", field + ":" + readiness); }
    var message;
    switch (readiness) {
        case ReadinessValue_disabled: {
            message = formatIfResources(Rez.Strings.readinessFormatNotEnabled, [title]);
            break;
        }
        case ReadinessValue_notPermitted: {
            message = formatIfResources(Rez.Strings.readinessFormatNotPermitted, [title]);
            break;
        }
        case ReadinessValue_notReady: {
            message = formatIfResources(Rez.Strings.readinessFormatNotReady, [title]);
            break;
        }
        default: {
            message = formatIfResources(Rez.Strings.readinessFormatNotReadyUnknown, [title]);
            break;
        }
    }
    showFeedback(message);
    return false;
}

}