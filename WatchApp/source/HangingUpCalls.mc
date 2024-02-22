using Toybox.Communications;
using Toybox.WatchUi;

function revealCallInProgress() {
    var callState = getCallState() as DismissedCallInProgress;
    setCallState(new CallInProgress(callState.phone));
}

function hangupCallInProgress() {
    var msg = {
        "cmd" => "hangup",
    };
    dump("outMsg", msg);
    var listener = new HangupCommListener();
    listener.onStart();
    Communications.transmit(msg, null, listener);
}

class HangupCommListener extends Communications.ConnectionListener {
    var progressBar as WatchUi.ProgressBar;
    var timer = new Timer.Timer();

    function initialize() {
        self.progressBar = new WatchUi.ProgressBar(
            "Hanging up",
            null
        );
        Communications.ConnectionListener.initialize();
    }

    function onStart() {
        WatchUi.pushView(
            progressBar,
            null,
            WatchUi.SLIDE_DOWN
        );
    }

    function onComplete() {
        progressBar.setProgress(100.0);
        progressBar.setDisplayString("Done.");
        timer.start(method(:dismiss), 1000, false);
    }

    function onError() {
        progressBar.setProgress(0.0);
        progressBar.setDisplayString("Hangup failed.");
        timer.start(method(:dismiss), 1000, false);
    }

    function dismiss() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
