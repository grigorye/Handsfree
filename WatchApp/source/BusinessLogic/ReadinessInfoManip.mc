import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

(:background, :glance, :readiness)
const ReadinessValue_disabled = "d";
(:background, :glance, :readiness)
const ReadinessValue_notPermitted = "p";
(:background, :glance, :readiness)
const ReadinessValue_ready = "r";
(:background, :glance, :readiness)
const ReadinessValue_notReady = "n";

(:readiness)
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
