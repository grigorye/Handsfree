import Toybox.WatchUi;
import Toybox.Application;

module Routing {

(:background, :noCompanion)
function companionInfoDidChangeIfInApp() as Void {
}

(:background, :typecheck([disableBackgroundCheck]), :companion)
function companionInfoDidChangeIfInApp() as Void {
    if (!isActiveUiKindApp) {
        return;
    }
    if (companionStatus() == CompanionStatus_upToDate) {
        if (VT.viewStackEntryWithTag(V_installCompanion) != null) {
            VT.popToView(V_comm, WatchUi.SLIDE_RIGHT);
            routeToMainUI();
        }
    }
}

(:background)
function readinessInfoDidChangeIfInApp() as Void {
    if (debug) { _3(L_APP, "readinessInfoDidChange", Storage.getValue(ReadinessInfo_valueKey)); }
}

}