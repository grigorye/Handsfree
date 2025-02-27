import Toybox.WatchUi;
import Toybox.Application;

module Routing {

(:background, :lowMemory)
function companionInfoDidChangeIfInApp() as Void {
}

(:background, :typecheck([disableBackgroundCheck]), :noLowMemory)
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

(:background)
function readinessInfoDidChangeIfInApp() as Void {
    if (debug) { _3(L_APP, "readinessInfoDidChange", Storage.getValue(ReadinessInfo_valueKey)); }
}

}