import Toybox.Communications;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

module Req {

function hangupCallInProgress(phone as Phone) as Void {
    if (isIncomingCallPhone(phone)) {
        if (errorDebug) {
            System.error("isIncomingCallPhone: " + phone);
        } else {
            System.error("");
        }
    }
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_HANGUP).launch();
}

function acceptIncomingCall(phone as Phone) as Void {
    if (!isIncomingCallPhone(phone)) {
        if (errorDebug) {
            System.error("!isIncomingCallPhone: " + phone);
        } else {
            System.error("");
        }
    }
    deactivateRequestingAttentionTillRelaunch();
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_ACCEPT).launch();
    TemporalBroadcasting.startTemporalSubjectsBroadcastingWithSubjects(null);
}

function rejectIncomingCall(phone as Phone) as Void {
    if (!isIncomingCallPhone(phone)) {
        if (errorDebug) {
            System.error("!isIncomingCallPhone: " + phone);
        } else {
            System.error("");
        }
    }
    deactivateRequestingAttentionTillRelaunch();
    new CallActionTask(phone, CALL_IN_PROGRESS_ACTION_REJECT).launch();
}

function ignoreIncomingCall(phone as Phone) as Void {
    if (!isIncomingCallPhone(phone)) {
        if (errorDebug) {
            System.error("!isIncomingCallPhone: " + phone);
        } else {
            System.error("");
        }
    }
    exitToSystemFromCurrentView();
}

}