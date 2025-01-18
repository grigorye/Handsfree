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

(:background)
const L_STORAGE as LogComponent = "readinessInfo";

(:inline, :background, :typecheck(disableBackgroundCheck))
function setReadinessInfo(readinessInfo as ReadinessInfo) as Void {
    ReadinessInfoImp.setReadinessInfoImp(readinessInfo);
    if (isActiveUiKindApp) {
        Routing.readinessInfoDidChange();
    }
}

typedef Readiness as Lang.String;

(:inline, :background, :glance)
function readiness(readinessField as Lang.String) as Readiness {
    var readinessInfo = ReadinessInfoImp.getReadinessInfo();
    if (readinessInfo == null) {
        return ReadinessValue.notReady;
    }
    return readinessInfo[readinessField] as Readiness;
}

(:inline, :background)
function setReadinessInfoVersion(version as Version) as Void {
    if (debug) { _3(L_STORAGE, "setReadinessInfoVersion", version); }
    Storage.setValue("readinessInfoVersion.v1", version);
}

(:inline, :glance, :background)
function getReadinessInfoVersion() as Version | Null {
    var version = Storage.getValue("readinessInfoVersion.v1") as Version | Null;
    return version;
}

}
