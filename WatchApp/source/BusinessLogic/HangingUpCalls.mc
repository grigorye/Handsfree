using Toybox.Communications;
using Toybox.WatchUi;

function revealCallInProgress() as Void {
    var callState = getCallState() as DismissedCallInProgress;
    setCallState(new CallInProgress(callState.phone));
}

function hangupCallInProgress() as Void {
    var msg = {
        "cmd" => "hangup",
    };
    dump("outMsg", msg);
    setCallState(new HangingUp(PENDING));
    Communications.transmit(msg, null, new HangupCommListener());
}
