using Toybox.WatchUi;

class HangingUpView extends WatchUi.ProgressBar {
    function initialize() {
        WatchUi.ProgressBar.initialize(
            "Hanging up...",
            null
        );
    }
}
