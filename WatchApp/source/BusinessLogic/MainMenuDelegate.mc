using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Symbol;
        switch (id) {
            case :favorites: {
                openFavoritesView();
                break;
            }
            case :recents: {
                openRecentsView();
                break;
            }
            case :settings: {
                openSettingsView();
                break;
            }
        }
    }

    function onBack() as Void {
        // !!! This is Menu2InputDelegate.onBack *that does not* popup the view
        // when overriden, hence there's no need for trackBackFromView() here:
        // the current view is still the main menu.
        exitToSystemFromMainMenu();
    }
}

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
