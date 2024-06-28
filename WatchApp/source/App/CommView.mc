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
            unexpectedOnShow();
        }
    }

    function firstOnShow() as Void {
        dump("commView", "firstOnShow");
        onAppWillFinishLaunching();
        pushView("phones", getPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
        getRouter().updateRoute();
        onAppDidFinishLaunching();
    }

    function unexpectedOnShow() as Void {
        dump("commView", "unexpectedOnShow");
        switch (topView()) {
            case instanceof Confirmation: {
                var confirmationDelegate = topViewStackEntry().delegate as WatchUi.ConfirmationDelegate;
                dumpViewStack("workingAroundBackOnConfirmation");
                if (viewStack.size() < 2) {
                    System.error("viewStackIsMessedUp");
                }
                for (var i = 1; i < viewStack.size() - 1; i++) {
                    dump("commView.pushing", viewStack[i].tag);
                    WatchUi.pushView(viewStack[i].view, viewStack[i].delegate, WatchUi.SLIDE_IMMEDIATE);
                }
                confirmationDelegate.onResponse(CONFIRM_NO);
                break;
            }
            default: {
                System.error("unexpectedTopView: " + topViewStackEntry().tag);
            }
        }
    }
}
