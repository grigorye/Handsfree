import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

(:background)
const L_PHONES_STORAGE as LogComponent = "phones";

const L_PHONES_UI as LogComponent = "phonesUI";

module PhonesManip {

(:inline, :background)
function setPhonesVersion(version as Version) as Void {
    if (debug) { _3(L_PHONES_STORAGE, "savePhonesVersion", version); }
    Storage.setValue("phonesVersion.v1", version);
}

(:inline, :background)
function getPhonesVersion() as Version or Null {
    var phonesVersion = Storage.getValue("phonesVersion.v1") as Version or Null;
    return phonesVersion;
}

(:background)
const phonesStorageK as Lang.String = "phones.v1";

function getPhones() as Phones {
    var phones = Storage.getValue(phonesStorageK) as Phones or Null;
    if (phones != null) {
        return phones;
    } else {
        return [] as Phones;
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
    var phonesView = viewWithTag("phones") as PhonesView or Null;
    if (phonesView != null) {
        phonesView.updateFromPhones(phones);
    }
}

}
