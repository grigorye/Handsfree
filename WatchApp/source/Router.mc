using Toybox.WatchUi;
using Toybox.System;

var router = null as Router or Null;

class Router {
    function initialize() {
    }

    var callStateProgressBar = new WatchUi.ProgressBar("", 0.0);

    function updateRoute() {
        var callState = getCallState();
        switch(callState) {
            default:
                dump("unknownCallState", callState);
                crash();
                break;
            case instanceof CallInProgress:
                WatchUi.switchToView(new CallInProgressConfirmation(callState.phone), new CallInProgressConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
                break;
            case instanceof Ringing:
                WatchUi.switchToView(callStateProgressBar, null, WatchUi.SLIDE_IMMEDIATE);
                // callStateProgressBar.setDisplayString("Incoming" + "\n" + callState.phone["number"]);
                break;
            case instanceof Idle:
            case instanceof DismissedCallInProgress:                
                WatchUi.switchToView(new PhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                break;
        }
    }
}

