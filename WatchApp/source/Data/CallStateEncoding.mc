using Toybox.Lang;
using Toybox.Application;
using Toybox.System;

typedef CallStateData as Lang.Dictionary<Application.PropertyKeyType, Application.PropertyValueType>;

(:background)
function encodeCallState(someCallState as CallState) as CallStateData {
    dumpCallState("encodingCallState", someCallState);
    switch (someCallState) {
        case instanceof Idle:
            return { "state" => "idle" };
        case instanceof Ringing: {
            var callState = someCallState as Ringing;
            return { "state" => "ringing", "phone" => (callState as Ringing).phone };
        }
        case instanceof SchedulingCall: {
            var callState = someCallState as SchedulingCall;
            return { "state" => "schedulingCall", "phone" => callState.phone, "commStatus" => callState.commStatus };
        }
        case instanceof CallInProgress: {
            var callState = someCallState as CallInProgress;
            return { "state" => "callInProgress", "phone" => callState.phone };
        }
        case instanceof DismissedCallInProgress: {
            var callState = someCallState as DismissedCallInProgress;
            return { "state" => "dismissedCallInProgress", "phone" => callState.phone };
        }
        case instanceof HangingUp: {
            var callState = someCallState as HangingUp;
            return { "state" => "hangingUp", "commStatus" => callState.commStatus };
        }
        default: {
            System.error("Unknown call state: " + someCallState);
        }
    }
}

(:background, :glance)
function decodeCallState(callStateData as CallStateData or Null) as CallState or Null {
    if (callStateData == null) {
        dump("callStateDataIsNull", true);
        return null;
    }
    dump("callStateData", callStateData);
    var stateId = callStateData["state"] as Lang.String or Null;
    if (stateId == null) {
        System.error("Call state data missing state: " + callStateData);
    }
    switch (stateId) {
        case "idle":
            return new Idle();
        case "ringing":
            return new Ringing(callStateData["phone"] as Phone);
        case "schedulingCall":
            return new SchedulingCall(callStateData["phone"] as Phone, callStateData["commStatus"] as CommStatus);
        case "callInProgress":
            return new CallInProgress(callStateData["phone"] as Phone);
        case "dismissedCallInProgress":
            return new DismissedCallInProgress(callStateData["phone"] as Phone);
        case "hangingUp":
            return new HangingUp(callStateData["commStatus"] as CommStatus);
        default:
            System.error("Unknown call state: " + callStateData);
    }
}