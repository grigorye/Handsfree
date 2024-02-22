using Toybox.Lang;

function crash() {
    throw new ForceCrashException();
}

class ForceCrashException extends Lang.Exception {
    function initialize() {
        Exception.initialize();
    }
}
