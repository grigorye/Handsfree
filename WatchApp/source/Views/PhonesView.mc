using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;

class PhonesView extends WatchUi.Menu2 {
    function initialize() {
        WatchUi.Menu2.initialize({});
    }

    var oldPhones as Phones = [] as Phones;

    function updateFromCheckInStatus(checkInStatus as CheckInStatus) as Void {
        var title = "";
        switch (checkInStatus) {
            case CHECK_IN_IN_PROGRESS:
                title = "...";
                break;
            case CHECK_IN_SUCCEEDED:
                title = "Idle";
                break;
            case CHECK_IN_FAILED:
                title = "Sync Failed";
                break;
        }
        setTitle(decorateWithSourceVersion(title));
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
                System.error("Failed to delete menu item");
            }
        }
        var focusedItemId = getFocusedPhonesViewItemId();
        var focus = null as Lang.Number | Null;
        if (phones.size() > 0) {
            for (var i = 0; i < phones.size(); i++) {
                var phone = phones[i];
                var specialItem = specialItemForPhone(phone);
                if (specialItem != null) {
                    addItem(specialItem);
                    continue;
                }
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

function phonesView(callState as CallState, phones as Phones) as PhonesView {
    var phonesView = new PhonesView();
    phonesView.updateFromCallState(callState);
    phonesView.updateFromPhones(phones);
    return phonesView;
}

function decorateWithSourceVersion(title as Lang.String) as Lang.String {
    if (!isShowingSourceVersionEnabled()) {
        return title;
    }
    return title + "\n" + sourceVersion();
}

var noPhonesMenuItemId as Lang.Number = -1;
var crashMeMenuItemId as Lang.Number = -2;

function specialItemForPhone(phone as Phone) as WatchUi.MenuItem | Null {
    var phoneName = phone["name"] as Lang.String;
    if (phoneName.equals("Crash Me")) {
        return new WatchUi.MenuItem(
            phoneName, // label
            sourceVersion(), // subLabel
            phone["id"] as Lang.Number, // identifier
            {}
        );
    }
    return null;
}