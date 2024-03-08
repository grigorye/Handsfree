using Toybox.Lang;

typedef CallState as Idle or SchedulingCall or Ringing or CallInProgress or DismissedCallInProgress or HangingUp;

var callStateImp as CallState or Null;
var oldCallStateImp as CallState or Null;

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

function initialCallState() as CallState {
    return new Idle(); // new CallInProgress({ "number" => "1233", "name" => "VoiceMail", "id" => 23 });
}

function getOldCallState() as CallState {
    return oldCallStateImp as CallState;
}

function getCallState() as CallState {
    if (callStateImp == null) {
        callStateImp = initialCallState();
    }
    return callStateImp as CallState;
}

function setCallStateImp(callState as CallState) as Void {
    oldCallStateImp = callStateImp;
    callStateImp = callState;
}