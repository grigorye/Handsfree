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

    function deleteItem(index as Lang.Number) as Lang.Boolean | Null {
        if (Menu2.deleteItem(index) != null) {
            menuItemCount--;
            return true;
        }
        return null;
    }

    function deleteItems(index as Lang.Number, itemCount as Lang.Number) as Void {
        deleteNMenuItems(self, index, itemCount);
    }

    function deleteAllItems() as Void {
        deleteItems(0, menuItemCount);
    }

    function beginUpdate() as Void {
        menuItemCountOnUpdate = menuItemCount;
    }

    function endUpdate() as Void {
        conditionalWorkaroundNoRedrawForMenu2(self, menuItemCount < menuItemCountOnUpdate);
    }
}