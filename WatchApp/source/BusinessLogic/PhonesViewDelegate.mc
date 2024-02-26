using Toybox.WatchUi;
using Toybox.Lang;

class PhonesViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        var selectedPhone = null as Phone or Null;
        var phones = getPhones();
        for (var i = 0; i < phones.size(); i++) {
            var phone = phones[i];
            if (phone["id"] == id) {
                selectedPhone = phone;
                break;
            }
        }
        if (selectedPhone == null) {
            return;
        }
        if ((selectedPhone["name"] as Lang.String).equals("Crash Me")) {
            crash();
            return;
        }
        new CallTask(selectedPhone).launch();
    }

    function onBack() {
        var callState = getCallState();
        dumpCallState("onBackFromPhones", callState);
        switch (callState) {
            case instanceof DismissedCallInProgress: {
                dump("revealingDismissedCallInProgress", true);
                var newCallState = new CallInProgress((callState as DismissedCallInProgress).phone);
                setCallState(newCallState);
                break;
            }
            default: {
                routingBackToSystem = true;
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Required in Simulator.
                break;
            }
        }
    }
}
