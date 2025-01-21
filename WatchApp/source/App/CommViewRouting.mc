import Toybox.Lang;

function routeOnFirstShow() as Void {
    if (!isCompanionUpToDate()) {
        if (debug) { _2(L_COMM_VIEW, "noCompanionInfo"); }
        Navigation.openInstallCompanionView();
    } else {
        routeToMainUI();
    }
}

const minCompanionVersionName as Lang.String = "0.0.8";
const minCompanionVersionCode as Lang.Integer = 70;

function isCompanionUpToDate() as Lang.Boolean {
    var companionInfo = CompanionInfoImp.getCompanionInfo();
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
