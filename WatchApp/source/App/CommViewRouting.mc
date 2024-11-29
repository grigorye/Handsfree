import Toybox.Lang;

function routeOnFirstShow() as Void {
    if (!isCompanionUpToDate()) {
        if (debug) { _2(L_COMM_VIEW, "noCompanionInfo"); }
        openInstallCompanionView();
    } else {
        routeToMainUI();
    }
}

function isCompanionUpToDate() as Lang.Boolean {
    return CompanionInfoImp.getCompanionInfo() != null;
}

function routeToMainUI() as Void {
    appWillRouteToMainUI();
    openFavoritesView();
    getRouter().updateRoute();
    appDidRouteToMainUI();
}
