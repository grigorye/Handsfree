using Toybox.Lang;
using Toybox.System;

function trackOptimisticCallState(callState as CallStateImp) as Void {
    var optimisticCallStates = getOptimisticCallStates();
    callState.optimistic = true;
    optimisticCallStates.add(callState);
    setOptimisticCallStates(optimisticCallStates);
}

(:background)
function untrackOptimisticCallState(callState as CallStateImp) as Void {
    var optimisticCallStates = getOptimisticCallStates();
    if (!("" + nextOptimisticCallState()).equals("" + callState)) {
        System.error("untrack.unexpectedOptimisticCallState: " + callState + ", " + optimisticCallStates);
    }
    callState.optimistic = false;
    optimisticCallStates = optimisticCallStates.slice(1, null) as CallStates;
    setOptimisticCallStates(optimisticCallStates);
}

function isOptimisticCallState(callState as CallStateImp) as Lang.Boolean {
    return callState.optimistic;
}

(:background)
function nextOptimisticCallState() as CallStateImp or Null {
    return firstElement(getOptimisticCallStates() as Lang.Array) as CallStateImp or Null;
}

(:background)
function resetOptimisticCallStates() as Void {
    setOptimisticCallStates([]);
}
