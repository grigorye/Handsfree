using Toybox.Lang;

function setCallInProgress(number as Lang.String) as Void {
    var phones = getPhones();
    for (var i = 0; i < phones.size(); i++) {
        if(phones[i]["number"] == number) {
            setCallState(new CallInProgress(phones[i]));
            return;
        }
    }
}

function getCallState() as CallState {
    return getAppState().callState();
}

function setCallState(callState as CallState) as Void {
    if (false) {
        var callStateImp = appStateImp.callState();
        if (callStateImp.equals(callState)) {
            dumpCallState("setCallStateNoChange", callState);
            return;
        }
        if (callStateImp.toString().equals(callState.toString())) {
            dumpCallState("setCallStateNoChangeString", callState);
            return;
        }
    }
    appStateImp.setCallState(callState);
    dumpCallState("setCallState", callState);
    router.updateRoute();
}
