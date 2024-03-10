using Toybox.Application;
using Toybox.Lang;

typedef CallState as Idle or SchedulingCall or Ringing or CallInProgress or DismissedCallInProgress or HangingUp;

(:background, :glance)
var callStateImp as CallState or Null;
(:background, :glance)
var oldCallStateImp as CallState = new Idle();

(:background, :glance)
class CallStateImp {
    function dumpRep() as Lang.String {
        return "" + self;
    }
}

(:background, :glance)
function dumpCallState(tag as Lang.String, callState as CallStateImp or Null) as Void {
    if (callState == null) {
        dump(tag, "null");
        return;
    }
    dump(tag, callState.dumpRep());
}

(:background, :glance)
function initialCallState() as CallState {
    return new Idle(); // new CallInProgress({ "number" => "1233", "name" => "VoiceMail", "id" => 23 });
}

(:background, :glance)
function loadCallState() as CallState or Null {
    var callStateData = Application.Storage.getValue("callState.v1") as CallStateData or Null;
    var callState = decodeCallState(callStateData);
    if (callState != null) {
        dump("loadedCallState", callState.dumpRep());
        return callState as CallState;
    }
    dump("loadedCallState", "null");
    return null;
}

(:background, :typecheck(disableGlanceCheck))
function saveCallState(callState as CallState) as Void {
    if (showingGlance) {
        return;
    }
    Application.Storage.setValue("callState.v1", encodeCallState(callState));
}

function getOldCallState() as CallState {
    return oldCallStateImp as CallState;
}

(:background, :glance)
function getCallState() as CallState {
    if (callStateImp == null) {
        var loadedCallState = loadCallState();
        if (loadedCallState != null) {
            callStateImp = loadedCallState;
        } else {
            callStateImp = initialCallState();
        }
    }
    return callStateImp as CallState;
}

(:background, :glance)
function setCallStateImp(callState as CallState) as Void {
    oldCallStateImp = getCallState();
    callStateImp = callState;
    saveCallState(callState);
}