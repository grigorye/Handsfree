import Toybox.WatchUi;

module Routing {

function companionInfoDidChange() as Void {
    if (isCompanionUpToDate()) {
        if (VT.viewStackEntryWithTag(V.installCompanion) != null) {
            VT.popToView(V.comm, WatchUi.SLIDE_RIGHT);
            routeToMainUI();
            WatchUi.showToast("Connected!", null);
        }
    }
}

function readinessInfoDidChange() as Void {
    if (debug) { _3(L_APP, "readinessInfoDidChange", ReadinessInfoImp.getReadinessInfo()); }
}

}