using Toybox.WatchUi;

class WidgetViewDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        WatchUi.BehaviorDelegate.initialize();
    }

    function onSelect() {
        dump("widgetOnSelect", true);
        setRoutedCallStateImp(null);
        setPhonesViewImp(null);
        pushView("commView", new CommView(), null, WatchUi.SLIDE_BLINK);
        return true;
    }
}
