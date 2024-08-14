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
            requestSync();
            return;
        }
        var selectedPhone = null as Phone or Null;
        var phones = getPhones();
        for (var i = 0; i < phones.size(); i++) {
            var phone = phones[i];
            if (getPhoneId(phone).equals(id)) {
                selectedPhone = phone;
                break;
            }
        }
        if (selectedPhone == null) {
            return;
        }
        if (getPhoneName(selectedPhone).equals("Crash Me")) {
            System.error("Crashing!");
        }
        scheduleCall(selectedPhone);
    }

    function onBack() {
        // !!! This is Menu2InputDelegate.onBack *that does not* popup the view
        // when overriden, hence there's no need for trackBackFromView() here:
        // the current view is still the phones view.
        var callState = getCallState();
        _3(L_USER_ACTION, "phonesView.onBack.callState", callState);
        if (callState instanceof DismissedCallInProgress) {
            _2(L_USER_ACTION, "revealingDismissedCallInProgress");
            var newCallState = new CallInProgress(callState.phone);
            setCallState(newCallState);
        } else {
            exitToSystemFromPhonesView();
        }
    }
}
