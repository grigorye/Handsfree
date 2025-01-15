import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

module CompanionInfoManip {

(:background)
const L_STORAGE as LogComponent = "companionInfo";

(:inline, :background, :typecheck(disableBackgroundCheck))
function setCompanionInfo(companionInfo as CompanionInfo) as Void {
    CompanionInfoImp.setCompanionInfoImp(companionInfo);
    if (isActiveUiKindApp) {
        Routing.companionInfoDidChange();
    }
}

(:inline, :background)
function setCompanionInfoVersion(version as Version) as Void {
    if (debug) { _3(L_STORAGE, "setCompanionInfoVersion", version); }
    Storage.setValue("companionInfoVersion.v1", version);
}

(:inline, :glance, :background)
function getCompanionInfoVersion() as Version | Null {
    var version = Storage.getValue("companionInfoVersion.v1") as Version | Null;
    return version;
}

}
