using Toybox.WatchUi;
using Toybox.Application;

(:background, :glance)
var phonesImp as Phones or Null;

(:background, :glance)
function loadPhones() as Phones {
    var phones = Application.Storage.getValue("phones.v1") as Phones or Null;
    if (phones != null) {
        return phones as Phones;
    } else {
        return [] as Phones;
    }
}

(:background, :glance)
function getPhones() as Phones {
    if (phonesImp == null) {
        phonesImp = loadPhones();
    }
    return phonesImp as Phones;
}

(:background, :glance)
function setPhones(phones as Phones) as Void {
    dump("setPhones", phones);
    if (phones.toString().equals(getPhones().toString())) {
        dump("phonesUnchanged", true);
        return;
    }

    phonesImp = phones;
    Application.Storage.setValue("phones.v1", phones);

    updateUIForPhones();
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIForPhones() as Void {
    if (!getActiveUIKind().equals(ACTIVE_UI_APP)){
        return;
    }

    var phones = getPhones();

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
