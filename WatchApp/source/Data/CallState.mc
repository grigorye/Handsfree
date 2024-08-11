using Toybox.Application;
using Toybox.Lang;

typedef CallState as Idle or SchedulingCall or CallInProgress or DismissedCallInProgress or HangingUp or Accepting or Declining;

(:background, :glance)
var callStateImp as CallState or Null;

(:background, :glance)
class CallStateImp {
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
        dump("loadedCallState", callState);
        switch (callState) {
            case instanceof CallActing: {
                var adjustedLoadedCallState = new Idle();
                dump("adjustedLoadedCallState", adjustedLoadedCallState);
                return adjustedLoadedCallState;
            }
            default: {
                return callState as CallState;
            }
        }
    }
    dump("loadedCallState", "null");
    return null;
}

(:background, :glance)
function saveCallState(callState as CallState) as Void {
    Application.Storage.setValue("callState.v1", encodeCallState(callState));
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
    callStateImp = callState;
    saveCallState(callState);
}