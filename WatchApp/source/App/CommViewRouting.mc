import Toybox.Lang;
import Toybox.Application;

(:noCompanion)
function routeOnFirstShow() as Void {
    routeToMainUI();
}

(:companion)
function routeOnFirstShow() as Void {
    if (!isCompanionUpToDate()) {
        if (debug) { _2(L_COMM_VIEW, "noCompanionInfo"); }
        Navigation.openInstallCompanionView();
    } else {
        routeToMainUI();
    }
}

const minCompanionVersionName as Lang.String = "0.0.9";
(:glance)
const minCompanionVersionCode as Lang.Integer = 71;

(:companion, :glance)
function isCompanionUpToDate() as Lang.Boolean {
    var companionInfo = Storage.getValue(CompanionInfo_valueKey) as CompanionInfo | Null;
    if (companionInfo == null) {
        return false;
    }
    var companionVersionCode = CompanionInfoImp.getCompanionVersionCode(companionInfo);
    return companionVersionCode >= minCompanionVersionCode;
}

function routeToMainUI() as Void {
    appWillRouteToMainUI();
    Navigation.openFavoritesView();
    getRouter().updateRoute();
    appDidRouteToMainUI();
}
