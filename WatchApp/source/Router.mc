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
            case instanceof CallInProgress:
                WatchUi.switchToView(new CallInProgressConfirmation(callState.phone), new CallInProgressConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
                break;
            case instanceof Ringing:
                WatchUi.switchToView(callStateProgressBar, null, WatchUi.SLIDE_IMMEDIATE);
                // callStateProgressBar.setDisplayString("Incoming" + "\n" + callState.phone["number"]);
                break;
            default:
                // WatchUi.switchToView(new CallInProgressConfirmation(callState.phone), new CallInProgressConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
                WatchUi.switchToView(new PhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                break;
        }
    }
}

