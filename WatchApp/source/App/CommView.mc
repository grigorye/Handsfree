import Toybox.WatchUi;
import Toybox.Lang;

const L_COMM_VIEW as LogComponent = "commView";
const L_COMM_VIEW_CRITICAL as LogComponent = "commView";

class CommView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onShow() {
        if (viewDebug) { _2(L_COMM_VIEW, "onShow"); }
        if (VT.topView() == self) {
            firstOnShow();
        } else {
            if (viewDebug) {
                _3(L_COMM_VIEW_CRITICAL, "unexpectedOnShow", VT.viewStackTags());
                if (exiting) {
                    if (viewDebug) { _2(L_COMM_VIEW_CRITICAL, "poppingUpDueToExiting"); }
                    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                }
            }
        }
    }

    function firstOnShow() as Void {
        if (debug) { _2(L_COMM_VIEW, "firstOnShow"); }
        if (dismissedNotification) {
            if (viewDebug) { _2(L_COMM_VIEW, "dismissedNotification"); }
            exitToSystemFromCurrentView();
            return;
        }
        routeOnFirstShow();
    }
}

var exiting as Lang.Boolean = false;