using Toybox.WatchUi;

const L_COMM_VIEW as LogComponent = new LogComponent("commView", false);
const L_COMM_VIEW_CRITICAL as LogComponent = new LogComponent("commView", true);

class CommView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onShow() {
        _([L_COMM_VIEW, "onShow"]);
        if (topView() == self) {
            firstOnShow();
        } else {
            _([L_COMM_VIEW_CRITICAL, "unexpectedOnShow", viewStackTags()]);
        }
    }

    function firstOnShow() as Void {
        _([L_COMM_VIEW, "firstOnShow"]);
        appWillRouteToMainUI();
        pushView("phones", getPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
        getRouter().updateRoute();
        appDidRouteToMainUI();
    }
}
