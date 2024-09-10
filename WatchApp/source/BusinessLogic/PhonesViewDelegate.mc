using Toybox.WatchUi;
using Toybox.Lang;

class PhonesViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Number or Phone;
        if (id.equals(noPhonesMenuItemId)) {
            requestSync();
            return;
        }
        var phone = id as Phone;
        setFocusedPhonesViewItemId(getPhoneId(phone));
        preprocessSpecialPhone(phone);
        scheduleCall(phone);
    }

    function onBack() {
        popView(SLIDE_RIGHT);
    }
}
