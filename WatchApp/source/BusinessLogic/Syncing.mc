import Toybox.Application;
import Toybox.Lang;
import Toybox.Communications;

(:noLowMemory)
function requestSync() as Void {
    var msg = {
        cmdK => "syncMe"
    } as Lang.Object as Application.PersistableType;
    transmitWithRetry("syncMe", msg, new Communications.ConnectionListener());
}

function requestAllSubjects() as Void {
    var msg = {
        cmdK => Cmd.query,
        argsK => {
            QueryArgsK.subjects => [
                { QueryArgsK.subjectNameK => broadcastSubject, QueryArgsK.subjectVersionK => BackgroundSettings.broadcastListeningVersion()},
                { QueryArgsK.subjectNameK => phonesSubject, QueryArgsK.subjectVersionK => PhonesManip.getPhonesVersion() },
                { QueryArgsK.subjectNameK => recentsSubject, QueryArgsK.subjectVersionK => RecentsManip.getRecentsVersion() },
                { QueryArgsK.subjectNameK => audioStateSubject, QueryArgsK.subjectVersionK => AudioStateManip.getAudioStateVersion() },
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