import Toybox.WatchUi;
import Toybox.Lang;

class MainMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({});
        addItem(favoritesMenuItem(""));
        addItem(recentsMenuItem(""));
        addItem(settingsMenuItem(""));
    }

    function update() as Void {
        var title = titleFromCheckInStatus(checkInStatusImp);
        setTitle(title);
        var recentsItemIndex = findItemById(:recents);
        if (recentsItemIndex != null) {
            var recentsItem = getItem(recentsItemIndex);
            if (recentsItem != null) {
                recentsItem.setLabel(joinComponents(["Recents", missedCallsRep()], " "));
            }
        }
        workaroundNoRedrawForMenu2(self);
    }
}

(:inline)
function favoritesMenuItem(titlePrefix as Lang.String) as WatchUi.MenuItem {
    return new WatchUi.MenuItem(titlePrefix + "Favorites", null, :favorites, null);
}

(:inline)
function recentsMenuItem(titlePrefix as Lang.String) as WatchUi.MenuItem {
    return new WatchUi.MenuItem(joinComponents([titlePrefix + "Recents", missedCallsRep()], " "), null, :recents, null);
}

(:inline)
function settingsMenuItem(titlePrefix as Lang.String) as WatchUi.MenuItem {
    return new WatchUi.MenuItem(titlePrefix + "Settings", null, :settings, null);
}