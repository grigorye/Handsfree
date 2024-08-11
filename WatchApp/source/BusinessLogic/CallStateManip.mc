using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.System;

const L_CALL_STATE_MANIP as LogComponent = "callStateManip";
const L_CALL_STATE_UI_UPDATE as LogComponent = "callStateUI";

function setCallInProgress(number as Lang.String) as Void {
    var phones = getPhones();
    for (var i = 0; i < phones.size(); i++) {
        if((phones[i]["number"] as Lang.String) == number) {
            setCallState(new CallInProgress(phones[i]));
            return;
        }
    }
}

(:background, :glance)
function setCallState(callStateImp as CallState or CallActing) as Void {
    var callState = callStateImp as CallState;
    _([L_CALL_STATE, "set", callState]);
    setCallStateImp(callState);
    updateUIForCallState();
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIForCallState() as Void {
    var activeUiKind = getActiveUiKind();
    _([L_CALL_STATE_UI_UPDATE, "activeUiKind", activeUiKind]);
    switch (activeUiKind) {
        case ACTIVE_UI_NONE: {
            return;
        }
        case ACTIVE_UI_GLANCE: {
            WatchUi.requestUpdate();
            return;
        }
        case ACTIVE_UI_APP: {
            _([L_CALL_STATE_UI_UPDATE, "viewStack", viewStackTags()]);
            if (viewStackTagsEqual(["widget"])) {
                WatchUi.requestUpdate();
            } else {
                getRouter().updateRoute();
            }
            return;
        }
    }
}

function setCallStateIgnoringRouting(callState as CallState) as Void {
    _([L_CALL_STATE, "setIgnoringRouting", callState]);
    setCallStateImp(callState);
    setRoutedCallStateImp(callState);
}

(:typecheck(disableBackgroundCheck))
function updateUIForCallStateIgnoringRouting() as Void {
    if (getActiveUiKind().equals(ACTIVE_UI_NONE)) {
        return;
    }
    getPhonesView().updateFromCallState(getCallState());
    WatchUi.requestUpdate();
}
