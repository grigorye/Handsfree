using Toybox.WatchUi;

function getPhones() as Phones {
    return appStateImp.phones;
}

function setPhones(phones as Phones) as Void {
    appStateImp.phones = phones;

    if ((WatchUi has :getCurrentView) && (WatchUi.getCurrentView()[0] instanceof PhonesView)) {
        // Workaround for menu items not being updated visually until it is hidden and shown again.
        // https://forums.garmin.com/developer/connect-iq/f/discussion/7382/menu2-additem-does-not-work-on-fenix-5s
        dump("recreatingPhonesView", true);
        var phonesView = new PhonesView();
        // Beware that some stuff like the focused item isn't "recreated" below, as it's impossible to track/get it.
        phonesView.updateFromPhones(phones);
        phonesView.updateFromCallState(getCallState());
        setPhonesViewImp(phonesView);
        WatchUi.switchToView(phonesView, new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
    } else {
        dump("updatingPhonesInPlace", true);
        getPhonesView().updateFromPhones(phones);
        WatchUi.requestUpdate();
    }
}
