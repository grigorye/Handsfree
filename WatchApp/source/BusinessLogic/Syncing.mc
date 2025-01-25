import Toybox.Application;
import Toybox.Lang;
import Toybox.Communications;

module Req {

function requestAllSubjects() as Void {
    var msg = {
        cmdK => Cmd.query,
        argsK => {
            subjectsK => [
                { QueryArgsK.subjectNameK => broadcastSubject, QueryArgsK.subjectVersionK => BackgroundSettings.broadcastListeningVersion()},
                { QueryArgsK.subjectNameK => phonesSubject, QueryArgsK.subjectVersionK => X.phones.version() },
                { QueryArgsK.subjectNameK => recentsSubject, QueryArgsK.subjectVersionK => X.recents.version() },
                { QueryArgsK.subjectNameK => audioStateSubject, QueryArgsK.subjectVersionK => X.audioState.version() },
                { QueryArgsK.subjectNameK => readinessInfoSubject, QueryArgsK.subjectVersionK => X.readinessInfo.version() },
            ]
        }
    } as Lang.Object as Application.PersistableType;
    transmitWithRetry("reqAllSubjects", msg, new Communications.ConnectionListener());
}

(:background)
function requestSubjects(subjects as Lang.Array<Lang.String>) as Void {
    var subjectsArg = [];
    var subjectsCount = subjects.size();
    for (var i = 0; i < subjectsCount; i++) {
        var name = subjects[i];
        if (name.equals(broadcastSubject)) {
            subjectsArg.add({ QueryArgsK.subjectNameK => name, QueryArgsK.subjectVersionK => BackgroundSettings.broadcastListeningVersion()});
        } else {
            subjectsArg.add({ QueryArgsK.subjectNameK => name });
        }
    }
    var msg = {
        cmdK => Cmd.query,
        argsK => {
            subjectsK => subjectsArg
        }
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("syncSubjects");
    if (minDebug) { _3(LX_OUT_COMM, tag + ".requesting", msg); }
    Communications.transmit(msg, null, new DummyCommListener(tag));
}

}
