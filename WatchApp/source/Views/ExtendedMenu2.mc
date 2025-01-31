using Toybox.WatchUi;
using Toybox.Lang;

class ExtendedMenu2 extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({});
    }

    var menuItemCount as Lang.Number = 0;
    private var menuItemCountOnUpdate as Lang.Number = 0;

    function addItem(item as WatchUi.MenuItem) as Void {
        Menu2.addItem(item);
        menuItemCount++;
    }

    function deleteExistingItems() as Void {
        deleteNMenuItems(self, menuItemCount);
        menuItemCount = 0;
    }

    function beginUpdate() as Void {
        menuItemCountOnUpdate = menuItemCount;
    }

    function endUpdate() as Void {
        conditionalWorkaroundNoRedrawForMenu2(self, menuItemCount < menuItemCountOnUpdate);
    }
}