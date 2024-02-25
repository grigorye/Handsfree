using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Lang;

function popViewAfterDelay(view as WatchUi.View or WatchUi.ProgressBar) as Void {
    // new PopViewAfterDelayTask(view).launch();
    if (view == WatchUi.getCurrentView()[0]) {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class PopViewAfterDelayTask {
    var timer as Timer.Timer;
    var view as WatchUi.View;

    function initialize(view as WatchUi.View) {
        self.view = view;
        self.timer = new Timer.Timer();
    }

    function launch() as Void {
        poppingViews.add(view);
        timer.start(method(:pop), 1000, false);
    }

    function pop() as Void {
        var currentView = WatchUi.getCurrentView();
        if(currentView != view) {
            dump("pop", "View is not current view, not popping" + view);
            return;
        }
        if(poppingViews.indexOf(view) == null) {
            poppingViews.remove(view);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}

var poppingViews as Lang.Array<WatchUi.View> = [];
