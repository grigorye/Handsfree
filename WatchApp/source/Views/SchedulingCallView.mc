using Toybox.WatchUi;

class SchedulingCallView extends WatchUi.ProgressBar {
    function initialize(phone as Phone) {
        WatchUi.ProgressBar.initialize(
            "Calling" + "\n" + phone["number"],
            null
        );
    }
}
