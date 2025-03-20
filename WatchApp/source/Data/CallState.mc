import Toybox.Application;
import Toybox.Lang;

(:background, :glance)
const L_CALL_STATE as LogComponent = "callState";

typedef CallState as Idle or SchedulingCall or CallInProgress or DismissedCallInProgress or HangingUp or Accepting or Declining;

(:background)
var callStateImp as CallState or Null;

(:background, :glance)
class CallStateImp {
    var optimistic as Lang.Boolean = false;
}

(:background)
function initialCallState() as CallState {
    return new Idle();
}

(:background, :glance)
const Storage_callState = "S.1"; // The value stored *is not* phoneState subject.

(:background, :glance)
function loadCallState() as CallState or Null {
    var callStateData = Storage.getValue(Storage_callState) as CallStateData or Null;
    if (callStateData == null) {
        if (debug) { _2(L_CALL_STATE, "callStateDataIsNull"); }
        return null;
    }
    var callState = decodeCallState(callStateData);
    if (debug) { _3(L_CALL_STATE, "loaded", callState); }
    if (callState instanceof CallActing) {
        var adjustedCallState = new Idle() as CallState;
        if (debug) { _3(L_CALL_STATE, "adjustedLoaded", adjustedCallState); }
        return adjustedCallState;
    }
    return callState;
}

(:background)
function saveCallState(callState as CallState) as Void {
    if (debug) { _3(L_CALL_STATE, "saveCallState", callState); }
    Storage.setValue(Storage_callState, encodeCallState(callState));
}

(:background)
function getCallState() as CallState {
    if (callStateImp != null) {
        return callStateImp;
    }
    var loadedCallState = loadCallState();
    if (loadedCallState != null) {
        callStateImp = loadedCallState;
        return loadedCallState;
    }
    callStateImp = initialCallState();
    return callStateImp;
}

(:background)
function setCallStateImp(callState as CallState) as Void {
    callStateImp = callState;
    saveCallState(callState);
}