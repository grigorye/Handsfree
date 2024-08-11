using Toybox.Lang;
using Toybox.Communications;
using Toybox.System;

(:background)
const L_REMOTE_MSG as LogComponent = "<";

(:background)
function handleRemoteMessage(iqMsg as Communications.Message) as Void {
    _([L_REMOTE_MSG, "msg", iqMsg.data]);
    didSeeCompanion();
    var msg = iqMsg.data as Lang.Dictionary<Lang.String, Lang.Object>;
    var cmd = msg["cmd"] as Lang.String;
    var args = msg["args"] as Lang.Dictionary<Lang.String, Lang.Object>;
    if (isBeepOnCommuncationEnabled()) {
        beep(BEEP_TYPE_MESSAGE);
    }
    switch (cmd) {
        case "syncYou":
            var phonesArgs = args["setPhones"] as Lang.Dictionary<Lang.String, Lang.Object>;
            setPhones(phonesArgs["phones"] as Phones);
            if (!callStateIsOwnedByUs) {
                var phoneStateChangedArgs = args["phoneStateChanged"] as Lang.Dictionary<Lang.String, Lang.Object> or Null;
                if (phoneStateChangedArgs != null) {
                    handlePhoneStateChanged(phoneStateChangedArgs as Lang.Dictionary<Lang.String, Lang.Object>);
                }
                callStateIsOwnedByUs = true;
            } else {
                _([L_REMOTE_MSG, "callStateIsNotOwnedByUs", true]);
            }
            break;
        case "setPhones":
            setPhones(args["phones"] as Phones);
            break;
        case "phoneStateChanged":
            handlePhoneStateChanged(args);
            break;
        case "openAppFailed":
            var message = args["messageForWakingUp"] as Lang.String;
            openAppFailed(message);
            break;
    }
}

(:background)
const L_PHONE_STATE_CHANGED as LogComponent = "phoneStateChanged";

(:background)
function handlePhoneStateChanged(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    var callState = getCallState();
    _([L_PHONE_STATE_CHANGED, "oldCallState", callState]);
    var inIsHeadsetConnected = args["isHeadsetConnected"];
    if (inIsHeadsetConnected != null) {
        setIsHeadsetConnected(inIsHeadsetConnected as Lang.Boolean);
    }
    var phoneState = args["state"] as Lang.String;
    _([L_PHONE_STATE_CHANGED, "inPhoneState", phoneState]);
    if (!phoneState.equals("ringing")) {
        stopRequestingAttentionIfInApp();
    }
    switch (phoneState) {
        case "callInProgress":
            var inProgressNumber = args["number"] as Lang.String;
            var inProgressName = args["name"] as Lang.String or Null;
            _([L_PHONE_STATE_CHANGED, "inProgressNumber", inProgressNumber]);
            var inProgressPhone = {
                "number" => inProgressNumber,
                "id" => -3
            } as Phone;
            if (inProgressName != null) {
                setPhoneName(inProgressPhone, inProgressName as Lang.String);
            }
            switch (callState) {
                case instanceof DismissedCallInProgress:
                    var dismissedCallState = callState as DismissedCallInProgress;
                    var dismissedNumber = dismissedCallState.phone["number"] as Lang.String;
                    var dismissedButChanged = !dismissedNumber.equals(inProgressNumber);
                    _([L_PHONE_STATE_CHANGED, "dismissedButChanged", dismissedButChanged]);
                    if (dismissedButChanged) {
                        setCallState(new CallInProgress(inProgressPhone));
                    }
                    break;
                default:
                    setCallState(new CallInProgress(inProgressPhone));
                    break;
            }
            break;
        case "noCallInProgress":
            setCallState(new Idle());
            break;
        case "ringing":
            var ringingNumber = args["number"] as Lang.String;
            _([L_PHONE_STATE_CHANGED, "inRingingNumber", ringingNumber]);
            var ringingPhone = {
                "number" => ringingNumber,
                "id" => -4,
                "ringing" => true
            } as Phone;
            var ringingName = args["name"] as Lang.String or Null;
            if (ringingName != null) {
                setPhoneName(ringingPhone, ringingName as Lang.String);
            }
            setCallState(new CallInProgress(ringingPhone));
            openAppOnIncomingCallIfNecessary(ringingPhone);
            break;
    }
}