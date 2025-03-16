import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Background;

module TemporalBroadcasting {

(:background, :glance)
const Storage_temporalBroadcastListening = "temporalBroadcastListening.v1";

(:glance, :noLowMemory)
const subjectsForStartingTemporalBroadcasting = phoneStateSubject + appConfigSubject + phonesSubject + recentsSubject + audioStateSubject + readinessInfoSubject + companionInfoSubject;

(:glance, :lowMemory)
const subjectsForStartingTemporalBroadcasting = phoneStateSubject + appConfigSubject + phonesSubject + recentsSubject + audioStateSubject;

(:glance)
function triggerTemporalSubjectsBroadcasting() as Void {
    if (Properties.getValue(Settings_broadcastListeningK) as Lang.Boolean) {
        if (debug) { _2(L_APP, "temporalBroadcastListening.skippedDueToSettings"); }
        return;
    }
    var temporalBroadcastListening = Storage.getValue(Storage_temporalBroadcastListening) as Lang.Boolean | Null;
    if (temporalBroadcastListening != null && temporalBroadcastListening) {
        if (debug) { _2(L_APP, "temporalBroadcastListening.alreadyActive"); }
    } else {
        if (debug) { _2(L_APP, "temporalBroadcastListening.activated"); }
        Storage.setValue(Storage_temporalBroadcastListening, true);
        Req.requestSubjectsIfPossibleWithRetry(subjectsForStartingTemporalBroadcasting);
    }
    var fiveMinutes = new Time.Duration(5 * 60);
    var eventTime = Time.now().add(fiveMinutes);
    Background.registerForTemporalEvent(eventTime);
}

(:background)
function stopTemporalSubjectsBroadcasting() as Void {
    Storage.setValue(Storage_temporalBroadcastListening, false);
    Req.requestSubjects(appConfigSubject);
}

(:background, :glance)
function isTemporalSubjectBroadcastingActive() as Lang.Boolean {
    var temporalBroadcastListening = Storage.getValue(Storage_temporalBroadcastListening) as Lang.Boolean | Null;
    return temporalBroadcastListening != null && temporalBroadcastListening;
}

}