import Toybox.WatchUi;

(:widget)
class WidgetViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        if (debug) { _2(L_USER_ACTION, "widget.onSelect"); }
        pushView(V.comm, new CommView(), null, WatchUi.SLIDE_BLINK);
        return true;
    }
}
