using Toybox.Application;
using Toybox.Lang;
using Toybox.Communications;

function requestSync() as Void {
    var msg = {
        "cmd" => "syncMe"
    } as Lang.Object as Application.PersistableType;
    transmitWithRetry("syncMe", msg, new Communications.ConnectionListener());
}

function requestAllSubjects() as Void {
    var msg = {
        "cmd" => "query",
        "args" => {
            "subjects" => [
                { "name" => "phones", "version" => getPhonesVersion() }, 
                { "name" => "recents", "version" => getRecentsVersion() }
            ]
        }
    } as Lang.Object as Application.PersistableType;
    transmitWithRetry("syncPhones", msg, new Communications.ConnectionListener());
}

(:background)
function requestSubjects(subjects as Lang.Array<Lang.String>) as Void {
    var subjectsArg = [];
    var subjectsCount = subjects.size();
    for (var i = 0; i < subjectsCount; i++) {
        var name = subjects[i];
        subjectsArg.add({ "name" => name });
    }
    var msg = {
        "cmd" => "query",
        "args" => {
            "subjects" => subjectsArg
        }
    } as Lang.Object as Application.PersistableType;
    var tag = formatCommTag("syncSubjects");
    _3(LX_OUT_COMM, tag + ".requesting", msg);
    Communications.transmit(msg, null, new DummyCommListener(tag));
}