using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Lang;

(:background)
const L_STORAGE as LogComponent = "app";

const L_PHONES_UI as LogComponent = "phonesUI";

var phonesImp as Phones or Null;

function loadPhones() as Phones {
    var phones = Application.Storage.getValue("phones.v1") as Phones or Null;
    if (phones != null) {
        return phones;
    } else {
        return [] as Phones;
    }
}

(:background)
function savePhones(phones as Phones) as Void {
    _3(L_STORAGE, "savePhones", phones);
    Application.Storage.setValue("phones.v1", phones as [Application.PropertyValueType]);
}

function getPhones() as Phones {
    if (phonesImp == null) {
        phonesImp = loadPhones();
    }
    return phonesImp as Phones;
}

(:background)
function setPhones(phones as Phones) as Void {
    savePhones(phones);
    updateUIForPhonesIfInApp(phones);
}

(:background, :typecheck([disableBackgroundCheck]))
function updateUIForPhonesIfInApp(phones as Phones) as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    updateUIForPhones(phones);
}

function updateUIForPhones(phones as Phones) as Void {
    if (phonesImp == null) {
        // Phones were not ever loaded, hence there's no need to update.
        return;
    }
    if (phones.toString().equals((phonesImp as Phones).toString())) {
        _2(L_PHONES_UI, "phonesUnchanged");
        return;
    }
    phonesImp = phones;
    if ((WatchUi has :getCurrentView) && (WatchUi.getCurrentView()[0] instanceof PhonesView)) {
        // Workaround for menu items not being updated visually until it is hidden and shown again.
        // https://forums.garmin.com/developer/connect-iq/f/discussion/7382/menu2-additem-does-not-work-on-fenix-5s
        _2(L_PHONES_UI, "recreatingPhonesView");
        var phonesView = new PhonesView();
        // Beware that some stuff like the focused item isn't "recreated" below, as it's impossible to track/get it.
        phonesView.setFromPhones(phones);
        phonesView.updateFromCallState(getCallState());
        setPhonesViewImp(phonesView);
        switchToView("phones", phonesView, new PhonesViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
    } else {
        _2(L_PHONES_UI, "updatingPhonesInPlace");
        getPhonesView().updateFromPhones(phones);
        WatchUi.requestUpdate();
    }
}
