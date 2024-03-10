using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

class CommView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onShow() {
        dump("commView", "onShow");
        if (routingBackToSystem) {
            dump("routingBackToSystem", "true");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else {
            if (phonesViewImp == null) {
                onAppWillFinishLaunching();
                dump("settingInitialPhonesView", true);
                var phonesView = new PhonesView();
                phonesView.updateFromCallState(getOldCallState());
                phonesView.updateFromPhones(getPhones());
                setPhonesView(phonesView);
                WatchUi.pushView(getPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
                getRouter().updateRoute();
                onAppDidFinishLaunching();
            } else {
                dump("pushingBackPhonesView", true);
                WatchUi.pushView(getPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
            }
            return;
        }
    }
}

var routingBackToSystem as Lang.Boolean = false;
