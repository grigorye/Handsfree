using Toybox.WatchUi;

class CommView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onShow() {
        dump("commView", "onShow");
        if (topView() == self) {
            firstOnShow();
        } else {
            dumpViewStack("commView.unexpectedOnShow");
        }
    }

    function firstOnShow() as Void {
        dump("commView", "firstOnShow");
        appWillRouteToMainUI();
        pushView("phones", getPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
        getRouter().updateRoute();
        appDidRouteToMainUI();
    }
}
