using Toybox.Lang;
using Toybox.WatchUi;

function setCallInProgress(number as Lang.String) as Void {
    var phones = getPhones();
    for (var i = 0; i < phones.size(); i++) {
        if(phones[i]["number"] == number) {
            setCallState(new CallInProgress(phones[i]));
            return;
        }
    }
}

function setCallState(callState as CallState) as Void {
    dumpCallState("setCallState", callState);
    setCallStateImp(callState);
    getRouter().updateRoute();
}

function setCallStateIgnoringRouting(callState as CallState) as Void {
    dumpCallState("setCallStateIgnoringRouting", callState);
    setCallStateImp(callState);
    getPhonesView().updateFromCallState(callState);
    WatchUi.requestUpdate();
}
