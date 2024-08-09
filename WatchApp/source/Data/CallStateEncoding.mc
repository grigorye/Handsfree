using Toybox.Lang;
using Toybox.Application;
using Toybox.System;

typedef CallStateData as Lang.Dictionary<Application.PropertyKeyType, Application.PropertyValueType>;

(:background, :glance)
function encodeCallState(someCallState as CallState) as CallStateData {
    dump("encodingCallState", someCallState);
    switch (someCallState) {
        case instanceof Idle:
            return { "state" => "idle" };
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
            return { "state" => "hangingUp", "phone" => callState.phone, "commStatus" => callState.commStatus };
        }
        case instanceof Accepting: {
            var callState = someCallState as Accepting;
            return { "state" => "accepting", "phone" => callState.phone, "commStatus" => callState.commStatus };
        }
        case instanceof Declining: {
            var callState = someCallState as Declining;
            return { "state" => "declining", "phone" => callState.phone, "commStatus" => callState.commStatus };
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
        case "schedulingCall":
            return new SchedulingCall(callStateData["phone"] as Phone, callStateData["commStatus"] as CommStatus);
        case "callInProgress":
            return new CallInProgress(callStateData["phone"] as Phone);
        case "dismissedCallInProgress":
            return new DismissedCallInProgress(callStateData["phone"] as Phone);
        case "hangingUp":
            return new HangingUp(callStateData["phone"] as Phone, callStateData["commStatus"] as CommStatus);
        case "accepting":
            return new Accepting(callStateData["phone"] as Phone, callStateData["commStatus"] as CommStatus);
        case "declining":
            return new Declining(callStateData["phone"] as Phone, callStateData["commStatus"] as CommStatus);
        default:
            System.error("Unknown call state: " + callStateData);
    }
}