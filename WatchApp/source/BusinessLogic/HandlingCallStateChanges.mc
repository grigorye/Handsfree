import Toybox.Lang;

(:background)
const L_PHONE_STATE_CHANGED as LogComponent = "phoneStateChanged";

module Req {

(:background)
function handlePhoneStateChanged(state as PhoneState) as Void {
    var callState = getCallState();
    if (debug) { _3(L_PHONE_STATE_CHANGED, "oldCallState", callState); }
    var stateId = state[PhoneState_stateId] as Lang.String;
    _3(L_APP, "inPhoneState", stateId);
    if (!stateId.equals(PhoneStateId_ringing)) {
        stopRequestingAttentionIfInApp();
    }
    var optimisticCallState = nextOptimisticCallState();
    switch (stateId) {
        case PhoneStateId_offHook:
            // Account broadcasting postponed on ringing.
            TemporalBroadcasting.startTemporalSubjectsBroadcasting();
            var inProgressNumber = state[PhoneState_number] as Lang.String or Null;
            var inProgressName = state[PhoneState_name] as Lang.String or Null;
            if (debug) { _3(L_PHONE_STATE_CHANGED, "inProgressNumber", inProgressNumber); }
            if (optimisticCallState != null) {
                if (optimisticCallState instanceof CallInProgress) {
                    var phoneNumber = getPhoneNumber(optimisticCallState.phone);
                    if (((phoneNumber != null) && phoneNumber.equals(inProgressNumber)) || (inProgressNumber == null /* no permission in companion */)) {
                        if (debug) { _3(L_PHONE_STATE_CHANGED, "optimisticCallStateHit", optimisticCallState); }
                        var isCurrent = objectsEqual(callState, optimisticCallState);
                        untrackOptimisticCallState(optimisticCallState);
                        if (isCurrent) {
                            setCallState(optimisticCallState);
                        }
                        return;
                    }
                }
                if (debug) { _3(L_PHONE_STATE_CHANGED, "resetOptimisticCallStatesDueTo", optimisticCallState); }
                resetOptimisticCallStates();
            }
            var inProgressPhone = {
                PhoneField_number => inProgressNumber,
                PhoneField_id => -3
            } as Phone;
            if (inProgressName != null) {
                setPhoneName(inProgressPhone, inProgressName as Lang.String);
            }
            if (callState instanceof DismissedCallInProgress) {
                var dismissedNumber = callState.phone[PhoneField_number] as Lang.String;
                var dismissedButChanged = !dismissedNumber.equals(inProgressNumber);
                if (debug) { _3(L_PHONE_STATE_CHANGED, "dismissedButChanged", dismissedButChanged); }
                if (dismissedButChanged) {
                    setCallState(new CallInProgress(inProgressPhone));
                }
            } else {
                setCallState(new CallInProgress(inProgressPhone));
            }
            break;
        case PhoneStateId_idle:
            if (optimisticCallState != null) {
                if (optimisticCallState instanceof Idle) {
                    if (debug) { _3(L_PHONE_STATE_CHANGED, "optimisticCallStateHit", optimisticCallState); }
                    untrackOptimisticCallState(optimisticCallState);
                    updateUIForCallState();
                    return;
                }
                if (debug) { _3(L_PHONE_STATE_CHANGED, "resetOptimisticCallStatesDueTo", optimisticCallState); }
                resetOptimisticCallStates();
            }
            setCallState(new Idle());
            break;
        case PhoneStateId_ringing:
            var ringingNumber = state[PhoneState_number] as Lang.String;
            if (debug) { _3(L_PHONE_STATE_CHANGED, "inRingingNumber", ringingNumber); }
            var ringingPhone = {
                PhoneField_number => ringingNumber,
                PhoneField_id => -4,
                PhoneField_ringing => true
            } as Phone;
            var ringingName = state[PhoneState_name] as Lang.String or Null;
            if (ringingName != null) {
                setPhoneName(ringingPhone, ringingName as Lang.String);
            }
            resetOptimisticCallStates();
            setCallState(new CallInProgress(ringingPhone));
            openAppOnIncomingCallIfNecessary(ringingPhone);
            break;
    }
}

}