import Toybox.Application;
import Toybox.System;
import Toybox.Lang;

typedef CallStates as Lang.Array<CallStateImp>;

(:background)
const Storage_optimisticCallStates = "optimisticCallStates.v1";

(:background)
function getOptimisticCallStates() as CallStates {
    var encodedCallStates = Storage.getValue(Storage_optimisticCallStates) as [Lang.Dictionary<Lang.String, Lang.Object>] or Null;
    if (encodedCallStates != null) {
        return decodeOptimisticCallStates(encodedCallStates);
    } else {
        return [] as CallStates;
    }
}

(:background)
function setOptimisticCallStates(callStates as CallStates) as Void {
    if (debug) { _3(L_CALL_STATE, "setOptimisticCallStates", callStates); }
    Storage.setValue(Storage_optimisticCallStates, encodeOptimisticCallStates(callStates));
}

(:background)
function encodeOptimisticCallStates(callStates as CallStates) as [Application.PropertyValueType] {
    var encoded = [];
    var callStatesCount = callStates.size();
    for (var i = 0; i < callStatesCount; i++) {
        encoded.add(encodeOptimisticCallState(callStates[i]));
    }
    return encoded as [Application.PropertyValueType];
}

(:background)
function encodeOptimisticCallState(callState as CallStateImp) as Application.PropertyValueType {
    var encoded;
    switch (callState) {
        case instanceof Idle: {
            encoded = {
                "type" => "Idle"
            };
            break;
        }
        case instanceof CallInProgress: {
            encoded = {
                "type" => "CallInProgress",
                "phone" => (callState as CallInProgress).phone
            };
            break;
        }
        default:
            System.error("encodeOptimisticCallState.unexpectedCallState: " + callState);
    }
    return encoded as Application.PropertyValueType;
}

(:background)
function decodeOptimisticCallState(encoded as Lang.Dictionary<Lang.String, Lang.Object>) as CallStateImp {
    var type = encoded["type"] as Lang.String;
    var decoded;
    switch (type) {
        case "Idle": {
            decoded = new Idle();
            break;
        }
        case "CallInProgress": {
            decoded = new CallInProgress(encoded["phone"] as Phone);
            break;
        }
        default:
            decoded = null;
            System.error("decodeOptimisticCallState.unexpectedType: " + type);
    }
    decoded.optimistic = true;
    return decoded;
}

(:background)
function decodeOptimisticCallStates(encoded as [Lang.Dictionary<Lang.String, Lang.Object>]) as CallStates {
    var decoded = [] as CallStates;
    var encodedCount = encoded.size();
    for (var i = 0; i < encodedCount; i++) {
        decoded.add(decodeOptimisticCallState(encoded[i]));
    }
    return decoded;
}
