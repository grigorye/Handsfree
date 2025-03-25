import Toybox.Lang;
import Toybox.Application;

(:noCompanion)
function routeOnFirstShow() as Void {
    routeToMainUI();
}

(:companion)
function routeOnFirstShow() as Void {
    if (companionStatus() != CompanionStatus_upToDate) {
        if (debug) { _2(L_COMM_VIEW, "noCompanionInfo"); }
        Navigation.openInstallCompanionView();
    } else {
        routeToMainUI();
    }
}

(:glance)
enum CompanionStatus {
    CompanionStatus_notInstalled,
    CompanionStatus_outdated,
    CompanionStatus_upToDate,
}

(:companion, :glance)
function companionStatus() as CompanionStatus {
    var companionInfo = Storage.getValue(CompanionInfo_valueKey) as CompanionInfo | Null;
    if (companionInfo == null) {
        return CompanionStatus_notInstalled;
    }
    var companionVersionCode = CompanionInfoImp.getCompanionVersionCode(companionInfo);
    if (companionVersionCode >= minCompanionVersionCode) {
        return CompanionStatus_upToDate;
    } else {
        return CompanionStatus_outdated;
    }
}

function routeToMainUI() as Void {
    appWillRouteToMainUI();
    Navigation.openFavoritesView();
    getRouter().updateRoute();
    appDidRouteToMainUI();
}
