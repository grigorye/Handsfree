using Toybox.Lang;
using Toybox.Communications;
using Toybox.System;

function handleRemoteMessage(iqMsg as Communications.Message) {
    var msg = iqMsg.data as Lang.Dictionary<Lang.String, Lang.Object>;
    var cmd = msg["cmd"] as Lang.String;
    var args = msg["args"] as Lang.Dictionary<Lang.String, Lang.Object>;
    dump("inCmd", cmd);
    dump("inArgs", args);
    var callState = getCallState();
    dumpCallState("inCallState", callState);
    switch(cmd) {
        case "setPhones":
            setPhones(args["phones"] as Phones);
            break;
        case "callInProgress":
            var inProgressNumber = args["number"] as Lang.String;
            dump("inProgressNumber", inProgressNumber);
            switch(callState) {
                case instanceof DismissedCallInProgress:
                    var dismissedNumber = callState.phone["number"] as Lang.String;
                    var dismissedButChanged = !dismissedNumber.equals(inProgressNumber);
                    dump("inDismissedButChanged", dismissedButChanged);
                    if(dismissedButChanged) {
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
            setCallState(new Ringing(phoneForNumber(ringingNumber)));
            break;
    }
}
