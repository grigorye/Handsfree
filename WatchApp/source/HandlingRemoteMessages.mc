using Toybox.Lang;
using Toybox.Communications;
using Toybox.System;

function handleRemoteMessage(msg as Communications.Message) {
    var data = msg.data as Lang.Dictionary<Lang.String, Lang.Object>;
    var cmd = data["cmd"] as Lang.String;
    dump("inCmd", cmd);
    dump("inData", data);
    var callState = getCallState();
    dumpCallState("inCallState", callState);
    switch(cmd) {
        case "setPhones":
            setPhones(data["phones"] as Phones);
            break;
        case "callInProgress":
            var inProgressNumber = data["number"] as Lang.String;
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
            setCallState(null);
            break;
        case "ringing":
            var ringingNumber = data["number"] as Lang.String;
            setCallState(new Ringing(phoneForNumber(ringingNumber)));
            break;
    }
}
