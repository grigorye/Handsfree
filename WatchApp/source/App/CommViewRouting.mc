import Toybox.Lang;

function routeOnFirstShow() as Void {
    if (!isCompanionUpToDate()) {
        if (debug) { _2(L_COMM_VIEW, "noCompanionInfo"); }
        openInstallCompanionView();
    } else {
        routeToMainUI();
    }
}

const minCompanionVersionName as Lang.String = "0.0.7";
const minCompanionVersionCode as Lang.Integer = 69;

function isCompanionUpToDate() as Lang.Boolean {
    var companionInfo = CompanionInfoImp.getCompanionInfo();
    if (companionInfo == null) {
        return false;
    }
    return CompanionInfoImp.getCompanionVersionCode(companionInfo) >= minCompanionVersionCode;
}

function routeToMainUI() as Void {
    appWillRouteToMainUI();
    openFavoritesView();
    getRouter().updateRoute();
    appDidRouteToMainUI();
}
