using Toybox.WatchUi;

class PhonesView extends WatchUi.Menu2 {
    function initialize() {
        var callState = getCallState();
        var title = "Idle";
        switch(callState) {
            case instanceof DismissedCallInProgress:
                title = callState.phone["number"];
                break;
            default:
                break;
        }
        WatchUi.Menu2.initialize({
            :title => title
        });
        updateItems();
    }

    var oldPhones = [] as Phones;

    function onUpdate(dc) {
        updateItems();
        WatchUi.Menu2.onUpdate(dc);
    }

    function updateItems() {
        var phones = getPhones();
        if(oldPhones == phones) {
            return;
        }
        for(var i = 0; i < oldPhones.size(); i++) {
            deleteItem(i);
        }
        for(var i = 0; i < phones.size(); i++) {
            var phone = phones[i];
            var item = new WatchUi.MenuItem(
                phone["name"], // label
                phone["number"], // subLabel
                phone["id"], // identifier
                {}
            );
            addItem(item);
        }
    }
}

class PhonesViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        var selectedPhone = null as Phone or Null;
        var phones = getPhones();
        for(var i = 0; i < phones.size(); i++) {
            var phone = phones[i];
            if(phone["id"] == id) {
                selectedPhone = phone;
                break;
            }
        }
        if(selectedPhone == null) {
            return;
        }
        if(selectedPhone["name"].equals("Crash Me")) {
            crash();
            return;
        }
        new CallTask(selectedPhone).launch();
    }
}
