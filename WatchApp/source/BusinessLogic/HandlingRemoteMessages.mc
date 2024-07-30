using Toybox.Lang;
using Toybox.Communications;
using Toybox.System;

(:background)
function handleRemoteMessage(iqMsg as Communications.Message) as Void {
    didSeeCompanion();
    var msg = iqMsg.data as Lang.Dictionary<Lang.String, Lang.Object>;
    var cmd = msg["cmd"] as Lang.String;
    var args = msg["args"] as Lang.Dictionary<Lang.String, Lang.Object>;
    dump("<- inCmd", cmd);
    dump("inArgs", args);
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
                dump("callStateIsNotOwnedByUs", true);
            }
            break;
        case "setPhones":
            setPhones(args["phones"] as Phones);
            break;
        case "phoneStateChanged":
            handlePhoneStateChanged(args);
            break;
    }
}

(:background)
function handlePhoneStateChanged(args as Lang.Dictionary<Lang.String, Lang.Object>) as Void {
    var callState = getCallState();
    dumpCallState("callState", callState);
    var inIsHeadsetConnected = args["isHeadsetConnected"];
    dump("inIsHeadsetConnected", inIsHeadsetConnected);
    if (inIsHeadsetConnected != null) {
        setIsHeadsetConnected(inIsHeadsetConnected as Lang.Boolean);
    }
    var phoneState = args["state"] as Lang.String;
    dump("inPhoneState", phoneState);
    switch (phoneState) {
        case "callInProgress":
            var inProgressNumber = args["number"] as Lang.String;
            var inProgressName = args["name"] as Lang.String or Null;
            dump("inProgressNumber", inProgressNumber);
            var inProgressPhone = {
                "number" => inProgressNumber,
                "id" => -3
            };
            if (inProgressName != null) {
                inProgressPhone["name"] = inProgressName as Lang.String;
            }
            switch (callState) {
                case instanceof DismissedCallInProgress:
                    var dismissedCallState = callState as DismissedCallInProgress;
                    var dismissedNumber = dismissedCallState.phone["number"] as Lang.String;
                    var dismissedButChanged = !dismissedNumber.equals(inProgressNumber);
                    dump("inDismissedButChanged", dismissedButChanged);
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
            dump("ringingNumber", ringingNumber);
            var ringingPhone = {
                "number" => ringingNumber,
                "id" => -4,
                "ringing" => true
            };
            var ringingName = args["name"] as Lang.String or Null;
            if (ringingName != null) {
                ringingPhone["name"] = ringingName as Lang.String;
            }
            setCallState(new CallInProgress(ringingPhone));
            openAppOnIncomingCallIfNecessary();
            break;
    }
}