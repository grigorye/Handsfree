var routedCallStateImp as CallState or Null;

function getRoutedCallState() as CallState {
    if (routedCallStateImp == null) {
        routedCallStateImp = new Idle();
    }
    return routedCallStateImp as CallState;
}

function setRoutedCallStateImp(callState as CallState or Null) as Void {
    dump("setRoutedCallStateImp", callState);
    routedCallStateImp = callState;
}
