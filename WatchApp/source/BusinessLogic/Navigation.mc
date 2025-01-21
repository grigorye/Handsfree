import Toybox.WatchUi;

module Navigation {

(:inline)
function openFavoritesView() as Void {
    VT.pushView(V.phones, newPhonesView(), new PhonesScreen.ViewDelegate(), WatchUi.SLIDE_LEFT);
}

(:inline)
function openRecentsView() as Void {
    VT.pushView(V.recents, newRecentsView(), new RecentsScreen.ViewDelegate(), WatchUi.SLIDE_LEFT);
    RecentsManip.recentsDidOpen();
}

(:inline)
function openSettingsView() as Void {
    VT.pushView(V.settings, newSettingsView(), new SettingsScreen.ViewDelegate(), WatchUi.SLIDE_LEFT);
}

(:inline)
function openInstallCompanionView() as Void {
    VT.pushView(V.installCompanion, Views.newInstallCompanionView(), new InstallCompanionViewDelegate(), WatchUi.SLIDE_LEFT);
}

}