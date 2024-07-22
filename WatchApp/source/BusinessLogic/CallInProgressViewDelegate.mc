using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

class CallInProgressViewDelegate extends WatchUi.ConfirmationDelegate {
    var phone as Phone;

    function initialize(phone as Phone) {
        self.phone = phone;
        WatchUi.ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        return onResponseForCallInProgressConfirmation(phone, response);
    }
}

function onResponseForCallInProgressConfirmation(phone as Phone, response as WatchUi.Confirm) as Lang.Boolean {
    dump("callInProgressConfirmationResponse", { "phone" => phone, "response" => response });
    trackBackFromView();
    if (response == WatchUi.CONFIRM_YES) {
        hangupCallInProgress(phone);
    } else {
        if (isIncomingCallPhone(phone)) {
            phone["ringing"] = false;
            hangupCallInProgress(phone);
            return true;
        }
        var callState = getCallState() as CallInProgress;
        dumpCallState("callState", callState);
        if (isExitToSystemAfterCallCompletionEnabled()) {
            exitToSystemFromPhonesView();
        } else {
            setCallStateIgnoringRouting(new DismissedCallInProgress(callState.phone));
        }
    }
    return true;
}
