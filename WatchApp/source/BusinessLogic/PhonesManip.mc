import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

module X {

(:background)
var phones as PhonesWrapper = new PhonesWrapper();

class PhonesWrapper extends VersionedSubject {
    
    (:background)
    function initialize() {
        VersionedSubject.initialize(
            2,
            1,
            "phones"
        );
    }

    function setSubjectValue(value as SubjectValue) as Void {
        VersionedSubject.setSubjectValue(value);
        PhonesManip.updateUIForPhonesIfInApp(value as Phones);
    }

    function defaultSubjectValue() as SubjectValue | Null {
        return noPhones as SubjectValue;
    }

    function value() as Phones {
        return subjectValue() as Phones;
    }
}

}
module PhonesManip {

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function updateUIForPhonesIfInApp(phones as Phones) as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    var phonesView = VT.viewWithTag(V.phones) as PhonesScreen.View or Null;
    if (phonesView != null) {
        phonesView.updateFromPhones(phones);
    }
}

}
