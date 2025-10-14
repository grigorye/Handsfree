import Toybox.Application;
import Toybox.Lang;

(:background, :glance, :foregroundSubjects)
const foregroundSubjectsEnabled = true;

(:background, :glance, :noForegroundSubjects)
const foregroundSubjectsEnabled = false;

(:background, :glance, :foregroundSubjects)
const foregroundOnlySubjects as Lang.Array<String> = [
    phonesSubject,
    recentsSubject,
];

(:background, :glance, :noForegroundSubjects)
const foregroundOnlySubjects as Lang.Array<String> = [];

(:background, :glance, :noForegroundSubjects)
function foregroundSubjects() as Lang.Array<Lang.String> {
    return [];
}

(:background, :glance, :foregroundSubjects)
function foregroundSubjects() as Lang.Array<Lang.String> {
    var subjects = Storage.getValue(Storage_foregroundSubjects) as Lang.Array<Lang.String> or Null;
    if (subjects == null) {
        return [];
    }
    return subjects;
}
