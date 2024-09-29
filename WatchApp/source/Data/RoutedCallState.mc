const L_ROUTED_CALL_STATE as LogComponent = "routedCallState";

var routedCallStateImp as CallState or Null;

function getRoutedCallState() as CallState {
    if (routedCallStateImp == null) {
        routedCallStateImp = new Idle();
    }
    return routedCallStateImp as CallState;
}

function setRoutedCallStateImp(callState as CallState or Null) as Void {
    if (debug) { _3(L_ROUTED_CALL_STATE, "set", callState); }
    routedCallStateImp = callState;
}
