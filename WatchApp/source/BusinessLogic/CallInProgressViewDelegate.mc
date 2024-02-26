using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.System;

class CallInProgressViewDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        WatchUi.ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        dump("confirmationResponse", response);
        if (response == WatchUi.CONFIRM_NO) {
            hangupCallInProgress();
        } else {
            var callState = getCallState() as CallInProgress;
            dumpCallState("callState", callState);
            setCallStateIgnoringRouting(new DismissedCallInProgress(callState.phone));
        }
        return true;
    }
}
