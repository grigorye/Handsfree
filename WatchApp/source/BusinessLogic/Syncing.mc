import Toybox.Application;
import Toybox.Lang;
import Toybox.Communications;

module Req {

function requestAllSubjects() as Void {
    var subjectsArg = [
        [broadcastSubject, BackgroundSettings.broadcastListeningVersion()],
        [phonesSubject, Storage.getValue(Phones_versionKey)],
        [recentsSubject, Storage.getValue(Recents_versionKey)],
        [audioStateSubject, Storage.getValue(AudioState_versionKey)],
        [readinessInfoSubject, Storage.getValue(ReadinessInfo_versionKey)]
    ] as Lang.Array;
    var msg = {
        cmdK => Cmd_query,
        subjectsK => subjectsArg
    } as Lang.Object;
    transmitWithRetry("reqAllSubjects", msg, new Communications.ConnectionListener());
}

(:background)
function requestSubjects(subjects as Lang.String) as Void {
    var subjectsArg = [];
    var subjectsCount = subjects.length();
    for (var i = 0; i < subjectsCount; i++) {
        var name = subjects.substring(i, i + 1) as Lang.String;
        if (lowMemory) {
            if (name.equals(readinessInfoSubject)) {
                continue;
            }
        }
        if (name.equals(broadcastSubject)) {
            subjectsArg.add([name, "" + BackgroundSettings.broadcastListeningVersion()]);
        } else {
            subjectsArg.add([name]);
        }
    }
    var msg = {
        cmdK => Cmd_query,
        subjectsK => subjectsArg
    } as Lang.Object;
    transmitWithoutRetry("syncSubjects", msg);
}

}
