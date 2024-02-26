using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;

class CallInProgressViewDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        WatchUi.ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        return onResponseForCallInProgressConfirmation(response);
    }
}

function onResponseForCallInProgressConfirmation(response as WatchUi.Confirm) as Lang.Boolean {
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
