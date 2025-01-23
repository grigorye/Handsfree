import Toybox.Lang;
import Toybox.Application;

typedef ReadinessInfo as Lang.Dictionary<String, Application.PropertyValueType>;

module ReadinessField {

(:inline, :background, :glance)
const essentials = "e";
(:inline, :background, :glance)
const outgoingCalls = "o";
(:inline, :background, :glance)
const recents = "r";
(:inline, :background, :glance)
const incomingCalls = "i";
(:inline, :background, :glance)
const starredContacts = "s";

}

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
