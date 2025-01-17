import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

(:background)
const L_PHONES_STORAGE as LogComponent = "phones";

const L_PHONES_UI as LogComponent = "phonesUI";

module PhonesManip {

(:background)
const phonesVersionStorageK as Lang.String = "phonesVersion.v1";

(:inline, :background)
function setPhonesVersion(version as Version) as Void {
    if (debug) { _3(L_PHONES_STORAGE, "savePhonesVersion", version); }
    Storage.setValue(phonesVersionStorageK, version);
}

(:inline, :background)
function getPhonesVersion() as Version or Null {
    var phonesVersion = Storage.getValue(phonesVersionStorageK) as Version or Null;
    return phonesVersion;
}

(:background)
const phonesStorageK as Lang.String = "phones.v1";

function getPhones() as Phones {
    var phones = Storage.getValue(phonesStorageK) as Phones or Null;
    if (phones != null) {
        return phones;
    } else {
        return noPhones;
    }
}

(:inline, :background)
function savePhones(phones as Phones) as Void {
    if (debug) { _3(L_PHONES_STORAGE, "savePhones", phones); }
    Storage.setValue(phonesStorageK, phones as [Application.PropertyValueType]);
}

(:inline, :background)
function setPhones(phones as Phones) as Void {
    savePhones(phones);
    updateUIForPhonesIfInApp(phones);
}

(:inline, :background, :typecheck([disableBackgroundCheck]))
function updateUIForPhonesIfInApp(phones as Phones) as Void {
    if (isActiveUiKindApp) {
        updateUIForPhones(phones);
    }
}

function updateUIForPhones(phones as Phones) as Void {
    var phonesView = VT.viewWithTag(V.phones) as PhonesView or Null;
    if (phonesView != null) {
        phonesView.updateFromPhones(phones);
    }
}

}
