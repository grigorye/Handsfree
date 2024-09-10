using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.System;

const L_CALL_STATE_MANIP as LogComponent = "callStateManip";
const L_CALL_STATE_UI_UPDATE as LogComponent = "callStateUI";

function setCallInProgress(number as Lang.String) as Void {
    var phones = getPhones();
    for (var i = 0; i < phones.size(); i++) {
        if ((phones[i]["number"] as Lang.String) == number) {
            setCallState(new CallInProgress(phones[i]));
            return;
        }
    }
}

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
    updateUIForCallStateInForeground();
}

(:glance, :typecheck(disableGlanceCheck))
function updateUIForCallStateInForeground() as Void {
    _3(L_CALL_STATE_UI_UPDATE, "activeUiKind", activeUiKind);
    switch (activeUiKind) {
        case ACTIVE_UI_NONE: {
            return;
        }
        case ACTIVE_UI_GLANCE: {
            WatchUi.requestUpdate();
            return;
        }
        case ACTIVE_UI_APP: {
            updateUIForCallStateInApp();
            return;
        }
    }
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
