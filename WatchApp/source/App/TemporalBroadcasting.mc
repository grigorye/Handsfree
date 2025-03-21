import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Background;

module TemporalBroadcasting {

(:background, :glance)
const Storage_temporalBroadcastListening = "B" + valueKeySuffix;

(:glance, :noLowMemory)
const subjectsForStartingTemporalBroadcasting = phoneStateSubject + appConfigSubject + phonesSubject + recentsSubject + audioStateSubject + readinessInfoSubject + companionInfoSubject;

(:glance, :lowMemory)
const subjectsForStartingTemporalBroadcasting = phoneStateSubject + appConfigSubject + phonesSubject + recentsSubject + audioStateSubject;

(:glance)
function startTemporalSubjectsBroadcasting() as Void {
    if (isBroadcastListeningEnabled()) {
        if (debug) { _2(L_APP, "temporalBroadcastListening.skippedDueToSettings"); }
        return;
    }
    var temporalBroadcastListening = Storage.getValue(Storage_temporalBroadcastListening) as Lang.Boolean | Null;
    if (temporalBroadcastListening != null && temporalBroadcastListening) {
        if (debug) { _2(L_APP, "temporalBroadcastListening.alreadyActive"); }
    } else {
        if (debug) { _2(L_APP, "temporalBroadcastListening.activated"); }
        Storage.setValue(Storage_temporalBroadcastListening, true);
        Req.requestSubjects(subjectsForStartingTemporalBroadcasting);
    }
}

(:glance, :typecheck(disableBackgroundCheck))
function scheduleStopTemporalSubjectsBroadcasting() as Void {
    if (isBroadcastListeningEnabled()) {
        if (debug) { _2(L_APP, "scheduleStopTemporalSubjectsBroadcasting.skippedDueToSettings"); }
        return;
    }
    if (debug) { _2(L_APP, "scheduleStopTemporalSubjectsBroadcasting.done"); }
    var fiveMinutes = new Time.Duration(5 * 60);
    var eventTime = Time.now().add(fiveMinutes);
    Background.registerForTemporalEvent(eventTime);
}

(:background, :glance)
function stopTemporalSubjectsBroadcasting() as Void {
    if (isBroadcastListeningEnabled()) {
        if (debug) { _2(L_APP, "stopTemporalSubjectsBroadcasting.skippedDueToSettings"); }
        return;
    }
    if (Storage.getValue(Storage_temporalBroadcastListening) as Lang.Boolean | Null) {
        if (debug) { _2(L_APP, "stopTemporalSubjectsBroadcasting.deactivated"); }
        Storage.setValue(Storage_temporalBroadcastListening, false);
        Req.requestSubjects(appConfigSubject);
    }
}

}