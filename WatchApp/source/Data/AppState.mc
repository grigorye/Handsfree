using Toybox.Lang;

class AppState {
    function callState() as CallState {
        if (callStateImp == null) {
            callStateImp = initialCallState();
        }
        return callStateImp as CallState;
    }
    
    function setCallState(callState as CallState) as Void {
        oldCallStateImp = callStateImp;
        callStateImp = callState;
    }

    function initialize() {
    }
}

var callStateImp as CallState or Null;

function initialCallState() as CallState {
    return new Idle(); // new CallInProgress({ "number" => "1233", "name" => "VoiceMail", "id" => 23 });
}

var oldCallStateImp as CallState or Null;

function getOldCallState() as CallState {
    return oldCallStateImp as CallState;
}
