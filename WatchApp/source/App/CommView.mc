import Toybox.WatchUi;

const L_COMM_VIEW as LogComponent = "commView";
const L_COMM_VIEW_CRITICAL as LogComponent = "commView";

class CommView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onShow() {
        if (debug) { _2(L_COMM_VIEW, "onShow"); }
        if (topView() == self) {
            firstOnShow();
        } else {
            if (debug) { _3(L_COMM_VIEW_CRITICAL, "unexpectedOnShow", viewStackTags()); }
        }
    }

    function firstOnShow() as Void {
        if (debug) { _2(L_COMM_VIEW, "firstOnShow"); }
        appWillRouteToMainUI();
        openFavoritesView();
        getRouter().updateRoute();
        appDidRouteToMainUI();
    }
}
