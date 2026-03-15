import Toybox.WatchUi;
import Toybox.Lang;

function recentsMenuTitle() as Lang.String {
    var missedCalls = missedCallsRep();
    var label = joinNonNullComponents([Rez.Strings.menuRecents, missedCalls], " ");
    return formatIfResources(Rez.Strings.mainMenuItemTitleFormat, [label]);
}

function newRecentsMenuItem() as WatchUi.MenuItem {
    return new WatchUi.MenuItem(recentsMenuTitle(), null, :recents, null);
}

(:settings)
function newSettingsMenuItem() as WatchUi.MenuItem {
    var title = formatIfResources(Rez.Strings.mainMenuItemTitleFormat, [Rez.Strings.menuSettings]);
    return new WatchUi.MenuItem(title, null, :settings, null);
}