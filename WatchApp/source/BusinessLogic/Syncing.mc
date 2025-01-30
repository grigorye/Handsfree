import Toybox.Application;
import Toybox.Lang;
import Toybox.Communications;

module Req {

function requestAllSubjects() as Void {
    var subjectsArg = [
        { QueryArgsK_subjectNameK => broadcastSubject, QueryArgsK_subjectVersionK => BackgroundSettings.broadcastListeningVersion()},
        { QueryArgsK_subjectNameK => phonesSubject, QueryArgsK_subjectVersionK => Storage.getValue(Phones_versionKey) },
        { QueryArgsK_subjectNameK => recentsSubject, QueryArgsK_subjectVersionK => Storage.getValue(Recents_versionKey) },
        { QueryArgsK_subjectNameK => audioStateSubject, QueryArgsK_subjectVersionK => Storage.getValue(AudioState_versionKey) },
        { QueryArgsK_subjectNameK => readinessInfoSubject, QueryArgsK_subjectVersionK => Storage.getValue(ReadinessInfo_versionKey) }
    ] as Lang.Array;
    var msg = {
        cmdK => Cmd_query,
        argsK => {
            subjectsK => subjectsArg
        }
    } as Lang.Object;
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
    } as Lang.Object;
    transmitWithoutRetry("syncSubjects", msg);
}

}
