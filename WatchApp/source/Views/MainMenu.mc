import Toybox.WatchUi;
import Toybox.Lang;

function newRecentsMenuItem() as WatchUi.MenuItem {
    var title = formatIfResources(Rez.Strings.mainMenuItemTitleFormat, [menuItemLabelFromRecents()]);
    return new WatchUi.MenuItem(title, null, :recents, null);
}

(:settings)
function newSettingsMenuItem() as WatchUi.MenuItem {
    var title = formatIfResources(Rez.Strings.mainMenuItemTitleFormat, [Rez.Strings.menuSettings]);
    return new WatchUi.MenuItem(title, null, :settings, null);
}