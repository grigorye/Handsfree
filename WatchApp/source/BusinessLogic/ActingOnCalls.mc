using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;

function revealCallInProgress() as Void {
    var callState = getCallState() as DismissedCallInProgress;
    setCallState(new CallInProgress(callState.phone));
}

function hangupCallInProgress(phone as Phone) as Void {
    if (isIncomingCallPhone(phone)) {
        System.error("isIncomingCallPhone: " + phone);
    }
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_HANGUP).launch();
}

function acceptIncomingCall(phone as Phone) as Void {
    if (!isIncomingCallPhone(phone)) {
        System.error("!isIncomingCallPhone: " + phone);
    }
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_ACCEPT).launch();
}

function rejectIncomingCall(phone as Phone) as Void {
    if (!isIncomingCallPhone(phone)) {
        System.error("!isIncomingCallPhone: " + phone);
    }
    phone["ringing"] = false;
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_REJECT).launch();
}