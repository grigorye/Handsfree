using Toybox.Communications;
using Toybox.WatchUi;

function revealCallInProgress() as Void {
    var callState = getCallState() as DismissedCallInProgress;
    setCallState(new CallInProgress(callState.phone));
}

function hangupCallInProgress(phone as Phone) as Void {
    new HangupCommTask(phone).launch();
}
