using Toybox.WatchUi;

(:watchApp)
class WidgetViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
        System.error("reachedStubForWidgetViewDelegate");
    }
}

(:widget)
class WidgetViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onSelect() {
        _2(L_USER_ACTION, "widget.onSelect");
        pushView("commView", new CommView(), null, WatchUi.SLIDE_BLINK);
        return true;
    }
}
