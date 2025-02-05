import Toybox.Application;
import Toybox.Lang;
import Toybox.Communications;

module Req {

(:background, :noLowMemory)
const allSubjects = appConfigSubject + phonesSubject + recentsSubject + audioStateSubject + readinessInfoSubject + companionInfoSubject;

(:background, :lowMemory)
const allSubjects = appConfigSubject + phonesSubject + recentsSubject + audioStateSubject;

function requestAllSubjects() as Void {
    var msg = msgForRequestSubjects(allSubjects);
    transmitWithRetry("reqAllSubjects", msg, new Communications.ConnectionListener());
}

(:background)
function requestSubjects(subjects as Lang.String) as Void {
    dumpF(L_APP, "requestSubjects");
    var msg = msgForRequestSubjects(subjects);
    transmitWithoutRetry("syncSubjects", msg);
}

(:background)
function msgForRequestSubjects(subjects as Lang.String) as Lang.Object {
    var subjectsArg = [];
    var subjectsCount = subjects.length();
    for (var i = 0; i < subjectsCount; i++) {
        var name = subjects.substring(i, i + 1) as Lang.String;
        if (name.equals(appConfigSubject)) {
            subjectsArg.add([name, "" + BackgroundSettings.appConfigVersion()]);
        } else {
            subjectsArg.add([name]);
        }
    }
    var msg = {
        cmdK => Cmd_query,
        subjectsK => subjectsArg
    } as Lang.Object;
    return msg;
}

}
