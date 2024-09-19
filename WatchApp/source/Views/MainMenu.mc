using Toybox.WatchUi;

class MainMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({});
        addItem(new MenuItem("Favorites", null, :favorites, null));
        addItem(new MenuItem(joinComponents(["Recents", missedCallsRep()], " "), null, :recents, null));
        addItem(new MenuItem("Settings", null, :settings, null));
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