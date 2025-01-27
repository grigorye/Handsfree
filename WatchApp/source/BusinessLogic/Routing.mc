import Toybox.WatchUi;
import Toybox.Application;

module Routing {

(:background, :glance, :typecheck([disableBackgroundCheck, disableGlanceCheck]))
function companionInfoDidChangeIfInApp() as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    if (isCompanionUpToDate()) {
        if (VT.viewStackEntryWithTag(V_installCompanion) != null) {
            VT.popToView(V_comm, WatchUi.SLIDE_RIGHT);
            routeToMainUI();
            if (WatchUi has :showToast) {
                WatchUi.showToast("Connected!", null);
            }
        }
    }
}

(:background, :glance)
function readinessInfoDidChangeIfInApp() as Void {
    if (debug) { _3(L_APP, "readinessInfoDidChange", Storage.getValue(ReadinessInfo_valueKey)); }
}

}