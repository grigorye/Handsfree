import Toybox.Application;
import Toybox.Lang;

(:background, :lowMemory)
function trackSubjectsConfirmed(extraSubjectsConfirmed as Lang.String) as Void {
}

(:background, :noLowMemory)
function trackSubjectsConfirmed(extraSubjectsConfirmed as Lang.String) as Void {
    if (!TemporalBroadcasting.isBroadcastListeningActive()) {
        _3(LX_REMOTE_MSG, "subjectsNotConfirmedDueNoListening", extraSubjectsConfirmed);
        return;
    }
    _3(LX_REMOTE_MSG, "extraSubjectsConfirmed", extraSubjectsConfirmed);
    var subjectsConfirmed = Storage.getValue(Storage_subjectsConfirmed) as Lang.String | Null;
    if (subjectsConfirmed == null) {
        subjectsConfirmed = "";
    }
    for (var i = 0; i < extraSubjectsConfirmed.length(); i++) {
        var name = extraSubjectsConfirmed.substring(i, i + 1) as Lang.String;
        if (subjectsConfirmed.find(name) == null) {
            subjectsConfirmed = subjectsConfirmed + name;
        }
    }
    _3(LX_REMOTE_MSG, "newSubjectsConfirmed", subjectsConfirmed);
    Storage.setValue(Storage_subjectsConfirmed, subjectsConfirmed);
}

(:glance, :noLowMemory)
function allSubjectsConfirmed(subjects as Lang.String) as Lang.Boolean {
    var subjectsConfirmed = Storage.getValue(Storage_subjectsConfirmed) as Lang.String | Null;
    if (subjectsConfirmed == null) {
        return false;
    }
    for (var i = 0; i < subjects.length(); i++) {
        var subject = subjects.substring(i, i + 1) as Lang.String;
        if (subjectsConfirmed.find(subject) == null) {
            return false;
        }
    }
    return true;
}
