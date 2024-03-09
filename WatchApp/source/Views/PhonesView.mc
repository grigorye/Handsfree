using Toybox.WatchUi;
using Toybox.Lang;

class PhonesView extends WatchUi.Menu2 {
    function initialize() {
        WatchUi.Menu2.initialize({});
    }

    var oldPhones as Phones = [] as Phones;

    function updateFromCheckInStatus(checkInStatus as CheckInStatus) as Void {
        switch (checkInStatus) {
            case CHECK_IN_IN_PROGRESS:
                setTitle("...");
                break;
            case CHECK_IN_SUCCEEDED:
                setTitle("Idle");
                break;
            case CHECK_IN_FAILED:
                setTitle("Sync Failed");
                break;        
        }
    }
    function updateFromCallState(callState as CallState) as Void {
        var title = "Idle";
        switch (callState) {
            case instanceof DismissedCallInProgress:
                title = (callState as DismissedCallInProgress).phone["number"] as Lang.String;
                setTitle(title);
                break;
            default:
                updateFromCheckInStatus(getCheckInStatus());
                break;
        }
    }

    function updateFromPhones(phones as Phones) as Void {
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
        var focusedItemId = getFocusedPhonesViewItemId();
        var focus = null as Lang.Number | Null;
        if (phones.size() > 0) {
            for (var i = 0; i < phones.size(); i++) {
                var phone = phones[i];
                var item = new WatchUi.MenuItem(
                    phone["name"] as Lang.String, // label
                    phone["number"] as Lang.String, // subLabel
                    phone["id"] as Lang.Number, // identifier
                    {}
                );
                if (item.getId() == focusedItemId) {
                    focus = i;
                }
                addItem(item);
            }
        } else {
            addItem(new WatchUi.MenuItem("No contacts", "selected", noPhonesMenuItemId, {}));
        }
        if (focus != null) {
           setFocus(focus);
        }
        oldPhones = phones;
    }

    function onShow() as Void {
        WatchUi.Menu2.onShow();
        // Workaround (as long as we employ it for CallInProgress) WatchUi.ConfirmationDelegate.onResponse not being called on back button press on devices
        // https://forums.garmin.com/developer/connect-iq/f/discussion/1386/handling-back-button-press-with-confirmation-view---vivoactive
        var callState = getCallState();
        dumpCallState("callStateOnPhonesShow", callState);
        if (callState instanceof CallInProgress) {
            dump("workingAroundNoOnResponse", true);
            onResponseForCallInProgressConfirmation(WatchUi.CONFIRM_NO);
        }
    }
}

function initialPhonesView() as PhonesView {
    var callState = getCallState();
    dumpCallState("callStateOnInitialPhonesView", callState);
    if (!(callState instanceof Idle)) {
        fatalError("CallState is not idle: we don't support this scenario yet.");
    }
    var phonesView = new PhonesView();
    phonesView.updateFromCallState(callState);
    phonesView.updateFromPhones(getPhones());
    return phonesView;
}

var noPhonesMenuItemId as Lang.Number = -1;
