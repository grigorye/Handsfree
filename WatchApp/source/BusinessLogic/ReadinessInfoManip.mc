import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

(:background, :glance)
const ReadinessValue_disabled = "d";
(:background, :glance)
const ReadinessValue_notPermitted = "p";
(:background, :glance)
const ReadinessValue_ready = "r";
(:background, :glance)
const ReadinessValue_notReady = "n";

module ReadinessInfoManip {

typedef Readiness as Lang.String;

(:inline, :background, :glance)
function readiness(readinessField as Lang.String) as Readiness {
    var readinessInfo = Storage.getValue(ReadinessInfo_valueKey) as ReadinessInfo | Null;
    if (readinessInfo == null) {
        return ReadinessValue_notReady;
    }
    return readinessInfo[readinessField] as Readiness;
}

}
