using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.System;

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
    dump("setCallState", callState);
    setCallStateImp(callState);
    updateUIForCallState();
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIForCallState() as Void {
    var activeUiKind = getActiveUiKind();
    dump("activeUiKind", activeUiKind);
    switch (activeUiKind) {
        case ACTIVE_UI_NONE: {
            return;
        }
        case ACTIVE_UI_GLANCE: {
            WatchUi.requestUpdate();
            return;
        }
        case ACTIVE_UI_APP: {
            dumpViewStack("viewStack");
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
    dump("setCallStateIgnoringRouting", callState);
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
