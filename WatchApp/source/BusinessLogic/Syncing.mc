import Toybox.Application;
import Toybox.Lang;
import Toybox.Communications;

module Req {

function requestAllSubjects() as Void {
    var msg = {
        cmdK => Cmd_query,
        argsK => {
            subjectsK => [
                { QueryArgsK_subjectNameK => broadcastSubject, QueryArgsK_subjectVersionK => BackgroundSettings.broadcastListeningVersion()},
                { QueryArgsK_subjectNameK => phonesSubject, QueryArgsK_subjectVersionK => X.phones.version() },
                { QueryArgsK_subjectNameK => recentsSubject, QueryArgsK_subjectVersionK => X.recents.version() },
                { QueryArgsK_subjectNameK => audioStateSubject, QueryArgsK_subjectVersionK => X.audioState.version() },
                { QueryArgsK_subjectNameK => readinessInfoSubject, QueryArgsK_subjectVersionK => X.readinessInfo.version() },
            ]
        }
    } as Lang.Object as Application.PersistableType;
    transmitWithRetry("reqAllSubjects", msg, new Communications.ConnectionListener());
}

(:background)
function requestSubjects(subjects as Lang.String) as Void {
    var subjectsArg = [];
    var subjectsCount = subjects.length();
    for (var i = 0; i < subjectsCount; i++) {
        var name = subjects.substring(i, i + 1) as Lang.String;
        if (name.equals(broadcastSubject)) {
            subjectsArg.add({ QueryArgsK_subjectNameK => name, QueryArgsK_subjectVersionK => BackgroundSettings.broadcastListeningVersion() });
        } else {
            subjectsArg.add({ QueryArgsK_subjectNameK => name });
        }
    }
    var msg = {
        cmdK => Cmd_query,
        argsK => {
            subjectsK => subjectsArg
        }
    } as Lang.Object as Application.PersistableType;
    transmitWithoutRetry("syncSubjects", msg);
}

}
