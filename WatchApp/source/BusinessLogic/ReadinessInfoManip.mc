import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

(:background, :glance, :noLowMemory)
const ReadinessValue_disabled = "d";
(:background, :glance, :noLowMemory)
const ReadinessValue_notPermitted = "p";
(:background, :glance, :noLowMemory)
const ReadinessValue_ready = "r";
(:background, :glance, :noLowMemory)
const ReadinessValue_notReady = "n";

(:noLowMemory)
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
