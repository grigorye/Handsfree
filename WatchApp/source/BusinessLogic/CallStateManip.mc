using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.System;

const L_CALL_STATE_UI_UPDATE as LogComponent = "callStateUI";

(:background)
function setCallState(callStateImp as CallState or CallActing) as Void {
    var callState = callStateImp as CallState;
    _3(L_CALL_STATE, "set", callState);
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
    _3(L_CALL_STATE_UI_UPDATE, "viewStack", viewStackTags());
    if (viewStackTagsEqual(["widget"])) {
        WatchUi.requestUpdate();
    } else {
        if (routerImp != null) {
            routerImp.updateRoute();
        } else {
            _2(L_CALL_STATE_UI_UPDATE, "routerImpIsNull");
        }
    }
}

function setCallStateIgnoringRouting(callState as CallState) as Void {
    _3(L_CALL_STATE, "setIgnoringRouting", callState);
    setCallStateImp(callState);
    setRoutedCallStateImp(callState);
}
