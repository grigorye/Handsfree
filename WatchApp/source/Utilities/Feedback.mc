using Toybox.WatchUi;
using Toybox.Lang;

function showFeedback(message as StringOrResource) as Void {
    var adjustedMessage = loadIfResource(message);
    var progressBar = new WatchUi.ProgressBar(
        adjustedMessage,
        null
    );
    progressBar.setProgress(0.0);
    WatchUi.pushView(
        progressBar,
        null,
        WatchUi.SLIDE_LEFT
    );
}
