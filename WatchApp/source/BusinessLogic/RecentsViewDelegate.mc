import Toybox.WatchUi;
import Toybox.Lang;

module RecentsScreen {

class ViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.Number or Recent;
        if (!lowMemory) {
            if (id.equals(noRecentsMenuItemId)) {
                Req.requestAllSubjects();
                return;
            }
        }
        var selectedRecent = id as Recent;
        Req.scheduleCall(phoneFromRecent(selectedRecent));
    }

    function onBack() {
        VT.popView(SLIDE_RIGHT);
    }
}

(:inline)
function phoneFromRecent(recent as Recent) as Phone {
    return {
        PhoneField.id => recent[RecentField.date],
        PhoneField.name => recent[RecentField.name],
        PhoneField.number => recent[RecentField.number]
    } as Phone;
}

}