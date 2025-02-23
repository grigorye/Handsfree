import Toybox.WatchUi;

class CallActingViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        VT.trackBackFromView();
        return true;
    }
}
