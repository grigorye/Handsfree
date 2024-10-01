import Toybox.WatchUi;

(:inline)
function openFavoritesView() as Void {
    pushView("phones", newPhonesView(), new PhonesViewDelegate(), WatchUi.SLIDE_LEFT);
}

(:inline)
function openRecentsView() as Void {
    pushView("recents", newRecentsView(), new RecentsViewDelegate(), WatchUi.SLIDE_LEFT);
    recentsDidOpen();
}

(:inline)
function openSettingsView() as Void {
    pushView("settings", newSettingsView(), new SettingsViewDelegate(), WatchUi.SLIDE_LEFT);
}
