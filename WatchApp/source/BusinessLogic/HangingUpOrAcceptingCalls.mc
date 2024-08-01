using Toybox.Communications;
using Toybox.WatchUi;

function revealCallInProgress() as Void {
    var callState = getCallState() as DismissedCallInProgress;
    setCallState(new CallInProgress(callState.phone));
}

function hangupOrAcceptCall(phone as Phone) as Void {
    new HangupOrAcceptCallTask(phone).launch();
}
