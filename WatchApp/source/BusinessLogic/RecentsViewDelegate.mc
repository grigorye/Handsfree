import Toybox.WatchUi;
import Toybox.Lang;

module RecentsScreen {

class ViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        RecentsManip.recentsDidOpen();
        var id = item.getId() as Lang.Number or Recent;
        if (id.equals(noRecentsMenuItemId)) {
            Req.requestSubjects(Req.allSubjects);
            return;
        }
        var selectedRecent = id as Recent;
        Req.scheduleCall(phoneFromRecent(selectedRecent));
    }

    function onBack() {
        RecentsManip.recentsDidOpen();
        VT.popView(SLIDE_RIGHT);
        if (VT.topViewIs(V_comm)) {
            exitToSystemFromCommView();
        }
    }
}

(:inline)
function phoneFromRecent(recent as Recent) as Phone {
    return {
        PhoneField_id => recent[RecentField_date],
        PhoneField_name => recent[RecentField_name],
        PhoneField_number => recent[RecentField_number]
    } as Phone;
}

}