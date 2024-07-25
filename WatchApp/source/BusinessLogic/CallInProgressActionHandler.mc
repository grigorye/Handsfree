using Toybox.Lang;

function onCallInProgressActionConfirmed(phone as Phone, confirmed as Lang.Boolean) as Void {
    if (confirmed) {
        hangupCallInProgress(phone);
    } else {
        if (isIncomingCallPhone(phone)) {
            phone["ringing"] = false;
            hangupCallInProgress(phone);
        } else {
            var callState = getCallState() as CallInProgress;
            dumpCallState("callState", callState);
            if (isExitToSystemAfterCallCompletionEnabled()) {
                exitToSystemFromPhonesView();
            } else {
                setCallStateIgnoringRouting(new DismissedCallInProgress(callState.phone));
            }
        }
    }
}
