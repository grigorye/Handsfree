import Toybox.Lang;

(:background, :glance)
class Idle extends CallStateImp {
    function initialize() {
        CallStateImp.initialize();
    }

    function toString() as Lang.String {
        return "Idle" + (optimistic ? "(optimistic)" : "");
    }
}
