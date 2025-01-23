import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

(:background, :glance)
module ReadinessValue {
    const disabled = "d";
    const notPermitted = "p";
    const ready = "r";
    const notReady = "n";
}

module ReadinessInfoManip {

typedef Readiness as Lang.String;

(:inline, :background, :glance)
function readiness(readinessField as Lang.String) as Readiness {
    var readinessInfo = X.readinessInfo.value();
    if (readinessInfo == null) {
        return ReadinessValue.notReady;
    }
    return readinessInfo[readinessField] as Readiness;
}

}
