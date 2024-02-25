using Toybox.WatchUi;
using Toybox.Lang;

class PhonesView extends WatchUi.Menu2 {
    function initialize() {
        WatchUi.Menu2.initialize({});
    }

    var oldPhones as Phones = [];

    // function onUpdate(dc) {
    //     updateItems();
    //     WatchUi.Menu2.onUpdate(dc);
    // }

    function updateFromCallState(callState as CallState) as Void {
        var title = "Idle";
        switch (callState) {
            case instanceof DismissedCallInProgress:
                title = (callState as DismissedCallInProgress).phone["number"] as Lang.String;
                break;
            default:
                break;
        }
        setTitle(title);

        var phones = getPhones();
        if (oldPhones.equals(phones)) {
            return;
        }
        for (var i = 0; i < oldPhones.size(); i++) {
            var existed = deleteItem(0);
            if (existed == null) {
                dump("failedIndex", i);
                fatalError("Failed to delete menu item");
            }
        }
        for (var i = 0; i < phones.size(); i++) {
            var phone = phones[i];
            var item = new WatchUi.MenuItem(
                phone["name"] as Lang.String, // label
                phone["number"] as Lang.String, // subLabel
                phone["id"] as Lang.Number, // identifier
                {}
            );
            addItem(item);
        }
        oldPhones = phones;
    }
}
