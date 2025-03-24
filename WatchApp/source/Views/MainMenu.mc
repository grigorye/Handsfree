import Toybox.WatchUi;
import Toybox.Lang;

function newRecentsMenuItem() as WatchUi.MenuItem {
    return new WatchUi.MenuItem(menuItemLabelFromRecents(), null, :recents, null);
}

(:settings)
function newSettingsMenuItem() as WatchUi.MenuItem {
    return new WatchUi.MenuItem(extraMenuItemPrefix + "Settings", null, :settings, null);
}