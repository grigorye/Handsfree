using Toybox.WatchUi;
using Toybox.Lang;

function showFeedback(message as Lang.String) as Void {
    var progressBar = new WatchUi.ProgressBar(
        message,
        null
    );
    progressBar.setProgress(0.0);
    WatchUi.pushView(
        progressBar,
        null,
        WatchUi.SLIDE_LEFT
    );
}
