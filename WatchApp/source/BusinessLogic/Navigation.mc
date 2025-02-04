import Toybox.WatchUi;

(:inline)
function openFavoritesView() as Void {
    VT.pushView(V.phones, newPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_LEFT);
}

(:inline)
function openRecentsView() as Void {
    VT.pushView(V.recents, newRecentsView(), new RecentsViewDelegate(), WatchUi.SLIDE_LEFT);
    RecentsManip.recentsDidOpen();
}

(:inline)
function openSettingsView() as Void {
    VT.pushView(V.settings, newSettingsView(), new SettingsViewDelegate(), WatchUi.SLIDE_LEFT);
}

(:inline)
function openInstallCompanionView() as Void {
    VT.pushView(V.installCompanion, Views.newInstallCompanionView(), new InstallCompanionViewDelegate(), WatchUi.SLIDE_LEFT);
}
