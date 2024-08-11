using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Lang;

(:background, :glance)
const L_PHONES as LogComponent = "phones";

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
    _([L_PHONES, "setPhones", phones]);
    if (phones.toString().equals(getPhones().toString())) {
        _([L_PHONES, "phonesUnchanged"]);
        return;
    }

    phonesImp = phones;
    Application.Storage.setValue("phones.v1", phones as [Application.PropertyValueType]);

    updateUIForPhones();
}

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIForPhones() as Void {
    if (!getActiveUiKind().equals(ACTIVE_UI_APP)){
        return;
    }

    var phones = getPhones();

    if ((WatchUi has :getCurrentView) && (WatchUi.getCurrentView()[0] instanceof PhonesView)) {
        // Workaround for menu items not being updated visually until it is hidden and shown again.
        // https://forums.garmin.com/developer/connect-iq/f/discussion/7382/menu2-additem-does-not-work-on-fenix-5s
        _([L_PHONES_VIEW, "recreatingPhonesView"]);
        var phonesView = new PhonesView();
        // Beware that some stuff like the focused item isn't "recreated" below, as it's impossible to track/get it.
        phonesView.setFromPhones(phones);
        phonesView.updateFromCallState(getCallState());
        setPhonesViewImp(phonesView);
        switchToView("phones", phonesView, new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
    } else {
        _([L_PHONES_VIEW, "updatingPhonesInPlace"]);
        getPhonesView().updateFromPhones(phones);
        WatchUi.requestUpdate();
    }
}
