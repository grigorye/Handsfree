using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;

function revealCallInProgress() as Void {
    var callState = getCallState() as DismissedCallInProgress;
    setCallState(new CallInProgress(callState.phone));
}

function hangupOrAcceptCall(phone as Phone) as Void {
    new CallActionTask(phone).launch();
}

function hangupCallInProgress(phone as Phone) as Void {
    if (isIncomingCallPhone(phone)) {
        System.error("isIncomingCallPhone: " + phone);
    }
    hangupOrAcceptCall(phone);
}

function acceptIncomingCall(phone as Phone) as Void {
    if (!isIncomingCallPhone(phone)) {
        System.error("!isIncomingCallPhone: " + phone);
    }
    hangupOrAcceptCall(phone);
}

function rejectIncomingCall(phone as Phone) as Void {
    if (!isIncomingCallPhone(phone)) {
        System.error("!isIncomingCallPhone: " + phone);
    }
    phone["ringing"] = false;
    hangupCallInProgress(phone);
}
