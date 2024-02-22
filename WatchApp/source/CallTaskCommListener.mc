using Toybox.Communications;
using Toybox.WatchUi;

class CallTaskCommListener extends Communications.ConnectionListener {
    var progressBar as WatchUi.ProgressBar;
    var phone as Phone;
    var timer = new Timer.Timer();

    function initialize(phone as Phone) {
        self.phone = phone;
        self.progressBar = new WatchUi.ProgressBar(
            "Calling" + "\n" + phone["number"],
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
        progressBar.setDisplayString("Completed.");
        timer.start(method(:dismiss), 1000, false);
    }

    function onError() {
        progressBar.setProgress(0.0);
        progressBar.setDisplayString("Dialing failed.");
        timer.start(method(:dismiss), 1000, false);
    }

    function dismiss() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
