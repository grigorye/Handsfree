import Toybox.Lang;
import Toybox.Application;

typedef SubjectValue as Application.PropertyValueType;

(:background, :glance)
class VersionedSubject {
    var valueKey as Lang.String;
    var versionKey as Lang.String;
    var tag as Lang.String;

    function defaultSubjectValue() as SubjectValue | Null {
        return null;
    }

    function initialize(
        valueFormat as Lang.Number,
        versionFormat as Lang.Number,
        tag as Lang.String
    ) {
        self.valueKey = tag + ".v" + valueFormat;
        self.versionKey = tag + "Version.v" + versionFormat;
        self.tag = tag;
    }

    function setSubjectValue(value as SubjectValue) as Void {
        if (debug) { _3(tag, "setValue", value as Lang.Object | Null); }
        Storage.setValue(valueKey, value);
    }

    function subjectValue() as SubjectValue | Null {
        var storedValue = Storage.getValue(valueKey);
        var returnedValue;
        if (storedValue != null) {
            returnedValue = storedValue;
        } else {
            returnedValue = defaultSubjectValue();
        }
        return returnedValue;
    }
    
    function setVersion(version as Version) as Void {
        Storage.setValue(versionKey, version);
    }

    function version() as Version | Null {
        return Storage.getValue(versionKey) as Version | Null;
    }
}