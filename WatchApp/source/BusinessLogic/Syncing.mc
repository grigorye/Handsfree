import Toybox.Application;
import Toybox.Lang;
import Toybox.Communications;

module Req {

(:background, :glance, :companion)
const companionInfoInAllSubjects = companionInfoSubject;

(:background, :glance, :noCompanion)
const companionInfoInAllSubjects = "";

(:background, :glance, :readiness)
const readinessInfoInAllSubjects = readinessInfoSubject;

(:background, :glance, :noReadiness)
const readinessInfoInAllSubjects = "";

(:background)
const allSubjects = appConfigSubject + phoneStateSubject + phonesSubject + recentsSubject + audioStateSubject + readinessInfoInAllSubjects + companionInfoInAllSubjects;

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function requestSubjects(subjects as Lang.String) as Void {
    dumpF(L_APP, "requestSubjects");
    _3(L_APP, "requestSubjects", subjects);
    var msg = msgForRequestSubjects(subjects);
    if (isActiveUiKindApp) {
        transmitWithRetry("syncSubjects", msg, new Communications.ConnectionListener());
    } else {
        transmitWithoutRetry("syncSubjects", msg);
    }
}

(:background, :glance)
function msgForRequestSubjects(subjects as Lang.String) as Lang.Object {
    var subjectsArg = [];
    var subjectsCount = subjects.length();
    for (var i = 0; i < subjectsCount; i++) {
        var name = subjects.substring(i, i + 1) as Lang.String;
        if (name.equals(appConfigSubject)) {
            subjectsArg.add([name, "" + BackgroundSettings.appConfigVersion()]);
        } else {
            var versionKey = versionKeyForSubject(name);
            if (versionKey != null) {
                var version = Storage.getValue(versionKey) as Version | Null;
                if (version != null) {
                    var versionValue = "" + version;
                    subjectsArg.add([name, versionValue]);
                } else {
                    subjectsArg.add([name]);
                }
            } else {
                subjectsArg.add([name]);
            }
        }
    }
    var msg = {
        cmdK => Cmd_query,
        subjectsK => subjectsArg
    } as Lang.Object;
    return msg;
}

}
