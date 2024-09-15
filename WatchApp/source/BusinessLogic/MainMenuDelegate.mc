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
                pushView("phones", newPhonesView(), new PhonesViewDelegate(), SLIDE_LEFT);
                break;
            }
            case :recents: {
                pushView("recents", newRecentsView(), new RecentsViewDelegate(), SLIDE_LEFT);
                recentsDidOpen();
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
