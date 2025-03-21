import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

(:background, :glance)
const Phones_valueKey = phonesSubject + valueKeySuffix;

(:background, :glance)
const Phones_versionKey = phonesSubject + versionKeySuffix;

module PhonesManip {

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIForPhonesIfInApp(phones as Phones) as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    var phonesView = VT.viewWithTag(V_phones) as PhonesScreen.View or Null;
    if (phonesView != null) {
        phonesView.updateFromPhones(phones);
    }
}

}
