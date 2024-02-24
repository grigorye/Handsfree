using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Communications;
using Toybox.System;

class CallInProgressConfirmation extends Toybox.WatchUi.Confirmation {
    function initialize(phone as Phone) {
        var message = phone["number"] + "\nKeep call in progress";
        Confirmation.initialize(message);
    }
}

class CallInProgressConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        WatchUi.ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        dump("confirmationResponse", response);
        if (response == WatchUi.CONFIRM_NO) {
            hangupCallInProgress();
        }
        var callState = getCallState() as CallInProgress;
        dumpCallState("callState", callState);
        setCallState(new DismissedCallInProgress(callState.phone));
        return true;
    }
}
