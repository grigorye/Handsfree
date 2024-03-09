using Toybox.Lang;

(:background)
class Idle extends CallStateImp {
    function initialize() {
        CallStateImp.initialize();
    }

    function dumpRep() as Lang.String {
        return "Idle";
    }
}
