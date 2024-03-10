using Toybox.Lang;
using Toybox.WatchUi;

function setCallInProgress(number as Lang.String) as Void {
    var phones = getPhones();
    for (var i = 0; i < phones.size(); i++) {
        if(phones[i]["number"] == number) {
            setCallState(new CallInProgress(phones[i]));
            return;
        }
    }
}

(:background, :glance)
function setCallState(callState as CallState) as Void {
    dumpCallState("setCallState", callState);
    setCallStateImp(callState);
    updateUIForCallState();
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIForCallState() as Void {
    dump("isRunningInBackground", isRunningInBackground);
    dump("showingGlance", showingGlance);
    if (isRunningInBackground) {
        return;
    }
    if (showingGlance) {
        WatchUi.requestUpdate();
        return;
    }
    if (!($ has :getRouter)) {
        dump("$hasGetRouter", $ has :getRouter);
    } else {
        getRouter().updateRoute();
    }
}

function setCallStateIgnoringRouting(callState as CallState) as Void {
    dumpCallState("setCallStateIgnoringRouting", callState);
    setCallStateImp(callState);
}

(:typecheck(disableBackgroundCheck))
function updateUIForCallStateIgnoringRouting() as Void {
    if (isRunningInBackground) {
        return;
    }
    getPhonesView().updateFromCallState(getCallState());
    WatchUi.requestUpdate();
}
