using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;

const L_PHONES_VIEW as LogComponent = "phonesView";

class PhonesView extends WatchUi.Menu2 {
    function initialize() {
        WatchUi.Menu2.initialize({});
    }

    var oldPhones as Phones = [] as Phones;

    function setTitleFromCheckInStatus(checkInStatus as CheckInStatus) as Void {
        if (!everSeenCompanion()) {
            setTitle(" ");
            return;
        }
        var title;
        switch (checkInStatus) {
            case CHECK_IN_IN_PROGRESS:
                title = "Syncing";
                break;
            case CHECK_IN_SUCCEEDED:
                title = "Idle";
                break;
            case CHECK_IN_FAILED:
                title = "Sync failed";
                break;
            case CHECK_IN_NONE:
                title = null;
                break;
            default: {
                title = null;
                System.error("unknownCheckInStatus: " + checkInStatus);
            }
        }
        _([L_PHONES_VIEW, "setTitle", title]);
        setTitle(joinComponents([title, headsetStatusRep()], " "));
    }

    function updateFromCallState(callState as CallState) as Void {
        switch (callState) {
            case instanceof DismissedCallInProgress:
                var title = (callState as DismissedCallInProgress).phone["number"] as Lang.String;
                setTitle(title);
                break;
            default:
                setTitleFromCheckInStatus(getCheckInStatus());
                break;
        }
    }

    function updateFromPhones(phones as Phones) as Void {
        _([L_PHONES_VIEW, "updatingFromPhones", phones]);
        if (phones.size() != 0 && oldPhones.equals(phones)) {
            _([L_PHONES_VIEW, "phonesNotChanged"]);
            return;
        }
        _([L_PHONES_VIEW, "phonesChanged"]);
        deleteExistingItems();
        setFromPhones(phones);
    }

    function deleteExistingItems() as Void {
        var menuItemCount;
        if (oldPhones.size() == 0) {
            menuItemCount = 1; // There should be a "No contacts", "Check Android" or "Syncing" item
        } else {
            menuItemCount = oldPhones.size();
        }
        for (var i = 0; i < menuItemCount; i++) {
            var existed = deleteItem(0);
            if (existed == null) {
                System.error("Failed to delete menu item at index " + i);
            }
        }
    }

    function setFromPhones(phones as Phones) as Void {
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
            if (everSeenCompanion()) {
                addItem(new WatchUi.MenuItem("No contacts selected", "", noPhonesMenuItemId, {}));
            } else {
                if (!didRequestCompanionInstallation) {
                    var title;
                    switch (getCheckInStatus()) {
                    case CHECK_IN_IN_PROGRESS:
                        title = "Syncing";
                        break;
                    case CHECK_IN_SUCCEEDED:
                        title = "Sync succeeded";
                        break;
                    case CHECK_IN_FAILED:
                        title = "Setup companion app";
                        break;
                    default:
                        title = "????";
                        break;
                    }
                    addItem(new WatchUi.MenuItem(title, null, noPhonesMenuItemId, {}));
                } else {
                    addItem(new WatchUi.MenuItem("Check Android", null, noPhonesMenuItemId, {}));
                }
            }
        }
        if (focus != null) {
           setFocus(focus);
        }
        oldPhones = phones;
    }
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

function updatePhonesView() as Void {
    if (phonesViewImp == null) {
        _([L_PHONES_VIEW, "phonesViewImp", phonesViewImp]);
        return;
    }
    getPhonesView().setTitleFromCheckInStatus(getCheckInStatus());
    getPhonesView().updateFromPhones(getPhones());
    workaroundNoRedrawForMenu2();
}
