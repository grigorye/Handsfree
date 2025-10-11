import Toybox.Application;
import Toybox.Lang;

(:background, :lowMemory)
const foregroundSubjectsEnabled = true;

(:background, :noLowMemory)
const foregroundSubjectsEnabled = false;

(:background, :glance, :lowMemory)
const foregroundOnlySubjects as Lang.Array<String> = [
    phonesSubject,
    recentsSubject,
];

(:background, :glance, :noLowMemory)
const foregroundOnlySubjects as Lang.Array<String> = [];

(:background, :glance, :noLowMemory)
function foregroundSubjects() as Lang.Array<Lang.String> {
    return [];
}

(:background, :glance, :lowMemory)
function foregroundSubjects() as Lang.Array<Lang.String> {
    var subjects = Storage.getValue(Storage_foregroundSubjects) as Lang.Array<Lang.String> or Null;
    if (subjects == null) {
        return [];
    }
    return subjects;
}
