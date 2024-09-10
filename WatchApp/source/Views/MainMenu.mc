using Toybox.WatchUi;

class MainMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({});
        addItem(new MenuItem("Favorites", null, :favorites, null));
        addItem(new MenuItem("Recents", null, :recents, null));
    }

    function update() as Void {
        var title = titleFromCheckInStatus(checkInStatusImp);
        setTitle(title);
        workaroundNoRedrawForMenu2(self);
    }
}