import Toybox.Lang;
import Toybox.Application;

typedef ReadinessInfo as Lang.Dictionary<String, Application.PropertyValueType>;

(:background, :glance)
const ReadinessField_essentials = "e";
(:background, :glance)
const ReadinessField_outgoingCalls = "o";
(:background, :glance)
const ReadinessField_recents = "r";
(:background, :glance)
const ReadinessField_incomingCalls = "i";
(:background, :glance)
const ReadinessField_starredContacts = "s";

module X {

(:background, :glance)
var readinessInfo as ReadinessInfoWrapper = new ReadinessInfoWrapper();

class ReadinessInfoWrapper extends VersionedSubject {

    function initialize() {
        VersionedSubject.initialize(
            1,
            1,
            "readinessInfo"
        );
    }

    function setSubjectValue(value as SubjectValue) as Void {
        VersionedSubject.setSubjectValue(value);
        Routing.readinessInfoDidChangeIfInApp();
    }

    (:background, :glance)
    function value() as ReadinessInfo | Null {
        return subjectValue() as ReadinessInfo | Null;
    }
}

}
