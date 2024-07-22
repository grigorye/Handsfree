using Toybox.Communications;
using Toybox.WatchUi;

function revealCallInProgress() as Void {
    var callState = getCallState() as DismissedCallInProgress;
    setCallState(new CallInProgress(callState.phone));
}

function hangupCallInProgress(phone as Phone) as Void {
    var cmd;
    if (isIncomingCallPhone(phone)) {
        cmd = "accept";
    } else {
        cmd = "hangup";
    }
    var msg = {
        "cmd" => cmd
    };
    dump("outMsg", msg);
    setCallState(new HangingUp(phone, PENDING));
    Communications.transmit(msg, null, new HangupCommListener());
}
