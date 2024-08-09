using Toybox.WatchUi;
using Toybox.Lang;

class PhonesViewDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Lang.String;
        setFocusedPhonesViewItemId(id);
        if (id == noPhonesMenuItemId) {
            if (everSeenCompanion()) {
                requestSync();
            } else {
                if (!didRequestCompanionInstallation) {
                    requestCompanionInstallation();
                } else {
                    requestSync();
                    didRequestCompanionInstallation = false;
                }
                getPhonesView().updateFromPhones(getPhones());
            }
            return;
        }
        var selectedPhone = null as Phone or Null;
        var phones = getPhones();
        for (var i = 0; i < phones.size(); i++) {
            var phone = phones[i];
            if ((phone["id"] as Lang.Number) == id) {
                selectedPhone = phone;
                break;
            }
        }
        if (selectedPhone == null) {
            return;
        }
        if ((selectedPhone["name"] as Lang.String).equals("Crash Me")) {
            System.error("Crashing!");
        }
        scheduleCall(selectedPhone);
    }

    function onBack() {
        // !!! This is Menu2InputDelegate.onBack *that does not* popup the view
        // when overriden, hence there's no need for trackBackFromView() here:
        // the current view is still the phones view.
        var callState = getCallState();
        dump("onBackFromPhones", callState);
        switch (callState) {
            case instanceof DismissedCallInProgress: {
                dump("revealingDismissedCallInProgress", true);
                var newCallState = new CallInProgress((callState as DismissedCallInProgress).phone);
                setCallState(newCallState);
                break;
            }
            default: {
                exitToSystemFromPhonesView();
            }
        }
    }
}
