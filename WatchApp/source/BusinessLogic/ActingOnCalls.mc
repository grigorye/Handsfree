using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;

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
    stopRequestingAttention();
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_ACCEPT).launch();
}

function rejectIncomingCall(phone as Phone) as Void {
    if (!isIncomingCallPhone(phone)) {
        System.error("!isIncomingCallPhone: " + phone);
    }
    stopRequestingAttention();
    dropRingingFromPhone(phone);
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_REJECT).launch();
}
