using Toybox.Lang;

function crash() as Void {
    throw new ForceCrashException();
}

class ForceCrashException extends Lang.Exception {
    function initialize() {
        Exception.initialize();
    }
}
