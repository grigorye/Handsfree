using Toybox.Lang;
using Toybox.Communications;
using Toybox.System;

(:background)
function handleRemoteMessage(iqMsg as Communications.Message) as Void {
    var msg = iqMsg.data as Lang.Dictionary<Lang.String, Lang.Object>;
    var cmd = msg["cmd"] as Lang.String;
    var args = msg["args"] as Lang.Dictionary<Lang.String, Lang.Object>;
    dump("<- inCmd", cmd);
    dump("inArgs", args);
    switch (cmd) {
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
    var phoneState = args["state"] as Lang.String;
    dump("inPhoneState", phoneState);
    switch (phoneState) {
        case "callInProgress":
            var inProgressNumber = args["number"] as Lang.String;
            dump("inProgressNumber", inProgressNumber);
            switch (callState) {
                case instanceof DismissedCallInProgress:
                    var dismissedCallState = callState as DismissedCallInProgress;
                    var dismissedNumber = dismissedCallState.phone["number"] as Lang.String;
                    var dismissedButChanged = !dismissedNumber.equals(inProgressNumber);
                    dump("inDismissedButChanged", dismissedButChanged);
                    if (dismissedButChanged) {
                        setCallState(new CallInProgress(phoneForNumber(inProgressNumber)));
                    }
                    break;
                default:
                    setCallState(new CallInProgress(phoneForNumber(inProgressNumber)));
                    break;
            }
            break;
        case "noCallInProgress":
            setCallState(new Idle());
            break;
        case "ringing":
            var ringingNumber = args["number"] as Lang.String;
            dump("inRingingNumber", ringingNumber);
            break;
    }
}
