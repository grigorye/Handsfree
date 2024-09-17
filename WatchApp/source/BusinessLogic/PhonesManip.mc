using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Lang;

(:background)
const L_PHONES_STORAGE as LogComponent = "phones";

const L_PHONES_UI as LogComponent = "phonesUI";

(:background)
function setPhonesVersion(version as Version) as Void {
    _3(L_PHONES_STORAGE, "savePhonesVersion", version);
    Application.Storage.setValue("phonesVersion.v1", version);
}

(:background)
function getPhonesVersion() as Version or Null {
    var phonesVersion = Application.Storage.getValue("phonesVersion.v1") as Version or Null;
    return phonesVersion;
}

function getPhones() as Phones {
    var phones = Application.Storage.getValue("phones.v1") as Phones or Null;
    if (phones != null) {
        return phones;
    } else {
        return [] as Phones;
    }
}

(:background)
function savePhones(phones as Phones) as Void {
    _3(L_PHONES_STORAGE, "savePhones", phones);
    Application.Storage.setValue("phones.v1", phones as [Application.PropertyValueType]);
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
    var phonesView = viewWithTag("phones") as PhonesView or Null;
    if (phonesView != null) {
        phonesView.updateFromPhones(phones);
    }
}
