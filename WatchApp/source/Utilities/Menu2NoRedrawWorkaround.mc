using Toybox.WatchUi;

function workaroundNoRedrawForMenu2(menu as WatchUi.Menu2) as Void {
    if (topView() != menu) {
        return;
    }
    if (!AppSettings.isMenu2NoRedrawWorkaroundEnabled) {
        WatchUi.requestUpdate();
    } else {
        var autoPoppingView = new AutoPoppingView();
        WatchUi.pushView(autoPoppingView, null, WatchUi.SLIDE_IMMEDIATE);
    }
}

class AutoPoppingView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}