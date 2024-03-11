using Toybox.WatchUi;

class CommView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onShow() {
        dump("commView", "onShow");
        if (phonesViewImp == null) {
            onAppWillFinishLaunching();
            WatchUi.pushView(getPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
            getRouter().updateRoute();
            onAppDidFinishLaunching();
        } else {
            dump("pushingBackPhonesView", true);
            WatchUi.pushView(getPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
