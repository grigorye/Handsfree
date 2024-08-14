using Toybox.Lang;
using Toybox.Application;
using Toybox.System;

(:background)
const L_ENCODING as LogComponent = "encoding";
(:background, :glance)
const L_DECODING as LogComponent = "decoding";

(:background, :glance)
typedef CallStateData as Lang.Dictionary<Application.PropertyKeyType, Application.PropertyValueType>;

(:background)
function encodeCallState(someCallState as CallState) as CallStateData {
    _3(L_ENCODING, "callState", someCallState);
    switch (someCallState) {
        case instanceof Idle:
            return { "state" => "idle" } as CallStateData;
        case instanceof SchedulingCall: {
            var callState = someCallState as SchedulingCall;
            return { "state" => "schedulingCall", "phone" => callState.phone, "commStatus" => callState.commStatus } as CallStateData;
        }
        case instanceof CallInProgress: {
            var callState = someCallState as CallInProgress;
            return { "state" => "callInProgress", "phone" => callState.phone } as CallStateData;
        }
        case instanceof DismissedCallInProgress: {
            var callState = someCallState as DismissedCallInProgress;
            return { "state" => "dismissedCallInProgress", "phone" => callState.phone } as CallStateData;
        }
        case instanceof CallActing: {
            var callState = someCallState as CallActing;
            return { "state" => callState.stateId(), "phone" => callState.phone, "commStatus" => callState.commStatus } as CallStateData;
        }
        default: {
            System.error("Unknown call state: " + someCallState);
        }
    }
}

(:background, :glance)
function decodeCallState(callStateData as CallStateData) as CallState {
    _3(L_DECODING, "callStateData", callStateData);
    var stateId = callStateData["state"];
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