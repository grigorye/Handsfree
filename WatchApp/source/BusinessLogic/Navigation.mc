import Toybox.WatchUi;

module Navigation {

(:inline)
function openFavoritesView() as Void {
    VT.pushView(V_phones, newPhonesView(), new PhonesScreen.ViewDelegate(), WatchUi.SLIDE_LEFT);
}

(:inline)
function openRecentsView() as Void {
    VT.pushView(V_recents, newRecentsView(), new RecentsScreen.ViewDelegate(), WatchUi.SLIDE_LEFT);
    RecentsManip.recentsDidOpen();
}

(:inline)
function openSettingsView() as Void {
    VT.pushView(V_settings, newSettingsView(), new SettingsScreen.ViewDelegate(), WatchUi.SLIDE_LEFT);
}

(:inline, :companion)
function openInstallCompanionView() as Void {
    VT.pushView(V_installCompanion, Views.newInstallCompanionView(), new InstallCompanionViewDelegate(), WatchUi.SLIDE_LEFT);
}

}