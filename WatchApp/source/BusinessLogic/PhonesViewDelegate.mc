import Toybox.WatchUi;
import Toybox.Lang;

module PhonesScreen {

class ViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Object;
        if (id == :recents) {
            Navigation.openRecentsView();
            return;
        }
        if (id == :settings) {
            Navigation.openSettingsView();
            return;
        }
        if (!lowMemory) {
            if (id.equals(noPhonesMenuItemId)) {
                requestAllSubjects();
                return;
            }
        }
        var phone = id as Phone;
        setFocusedPhonesViewItemId(getPhoneId(phone));
        if (preprocessSpecialPhone(phone)) {
            return;
        }
        scheduleCall(phone);
    }

    function onBack() {
        VT.popView(SLIDE_IMMEDIATE);
        if (VT.topViewIs(V.comm)) {
            exitToSystemFromCommView();
        }
    }
}

}