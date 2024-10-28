import Toybox.WatchUi;

(:inline)
function openFavoritesView() as Void {
    pushView(V.phones, newPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_LEFT);
}

(:inline)
function openRecentsView() as Void {
    pushView(V.recents, newRecentsView(), new RecentsViewDelegate(), WatchUi.SLIDE_LEFT);
    RecentsManip.recentsDidOpen();
}

(:inline)
function openSettingsView() as Void {
    pushView(V.settings, newSettingsView(), new SettingsViewDelegate(), WatchUi.SLIDE_LEFT);
}
