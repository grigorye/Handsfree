const L_ROUTED_CALL_STATE as LogComponent = new LogComponent("routedCallState", true);

var routedCallStateImp as CallState or Null;

function getRoutedCallState() as CallState {
    if (routedCallStateImp == null) {
        routedCallStateImp = new Idle();
    }
    return routedCallStateImp as CallState;
}

function setRoutedCallStateImp(callState as CallState or Null) as Void {
    _([L_ROUTED_CALL_STATE, "set", callState]);
    routedCallStateImp = callState;
}
