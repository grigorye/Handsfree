using Toybox.Lang;

function crash() as Void {
    throw new ForceCrashException();
}
function fatalError(msg as Lang.String) as Void {
    dump("fatalError", msg);
    throw new ForceCrashException();
}

class ForceCrashException extends Lang.Exception {
    function initialize() {
        Exception.initialize();
    }
}
