using Toybox.Lang;

typedef CallState as Idle or SchedulingCall or Ringing or CallInProgress or DismissedCallInProgress or HangingUp;

class CallStateImp {
    function dumpRep() as Lang.String {
        return "" + self;
    }
}

function dumpCallState(tag as Lang.String, callState as CallStateImp or Null) as Void {
    if (callState == null) {
        dump(tag, "null");
        return;
    }
    dump(tag, callState.dumpRep());
}
