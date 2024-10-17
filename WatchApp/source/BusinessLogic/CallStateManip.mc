import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

const L_CALL_STATE_UI_UPDATE as LogComponent = "callStateUI";

(:background)
function setCallState(callStateImp as CallState or CallActing) as Void {
    var callState = callStateImp as CallState;
    if (debug) { _3(L_CALL_STATE, "set", callState); }
    if (callStateImp instanceof Idle) {
        AudioStateImp.resetAudioState();
    }
    setCallStateImp(callState);
    updateUIForCallState();
}

(:background, :typecheck([disableBackgroundCheck]))
function updateUIForCallState() as Void {
    if (activeUiKind.equals(ACTIVE_UI_NONE)) {
        return;
    }
    updateUIForCallStateInApp();
}

function updateUIForCallStateInApp() as Void {
    if (debug) { _3(L_CALL_STATE_UI_UPDATE, "viewStack", viewStackTags()); }
    if (viewStackTagsEqual(["widget"])) {
        WatchUi.requestUpdate();
    } else {
        if (routerImp != null) {
            routerImp.updateRoute();
        } else {
            if (debug) { _2(L_CALL_STATE_UI_UPDATE, "routerImpIsNull"); }
        }
    }
}

function setCallStateIgnoringRouting(callState as CallState) as Void {
    if (debug) { _3(L_CALL_STATE, "setIgnoringRouting", callState); }
    setCallStateImp(callState);
    setRoutedCallStateImp(callState);
}
