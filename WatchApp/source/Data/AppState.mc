using Toybox.Lang;

class AppState {
    function callState() as CallState {
        return callStateImp;
    }
    
    function setCallState(callState as CallState) as Void {
        oldCallStateImp = callStateImp;
        callStateImp = callState;
    }

    var phones as Phones = [
        { "number" => "1233", "name" => "Crash Me", "id" => -1 },
        { "number" => "1233", "name" => "VoiceMail", "id" => 23 }
    ];
    
    function initialize() {
    }
}

var callStateImp as CallState = new Idle(); // new CallInProgress({ "number" => "1233", "name" => "VoiceMail", "id" => 23 });
var oldCallStateImp as CallState = callStateImp;

function getOldCallState() as CallState {
    return oldCallStateImp;
}
