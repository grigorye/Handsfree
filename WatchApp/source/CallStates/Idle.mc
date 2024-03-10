using Toybox.Lang;

(:background, :glance)
class Idle extends CallStateImp {
    function initialize() {
        CallStateImp.initialize();
    }

    function dumpRep() as Lang.String {
        return "Idle";
    }
}
