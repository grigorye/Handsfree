import Toybox.Communications;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

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
    deactivateRequestingAttentionTillRelaunch();
    dropRingingFromPhone(phone);
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_ACCEPT).launch();
}

function rejectIncomingCall(phone as Phone) as Void {
    if (!isIncomingCallPhone(phone)) {
        System.error("!isIncomingCallPhone: " + phone);
    }
    deactivateRequestingAttentionTillRelaunch();
    dropRingingFromPhone(phone);
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_REJECT).launch();
}
