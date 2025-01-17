import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

const L_PHONES_VIEW as LogComponent = "phonesView";

class PhonesView extends WatchUi.Menu2 {

    const predefinedItems as Lang.Array<WatchUi.MenuItem> = [
        newRecentsMenuItem(),
        newSettingsMenuItem()
    ];

    const predefinedItemsCount as Lang.Number = predefinedItems.size();

    function initialize(phones as Phones) {
        Menu2.initialize({});
        setTitle(statusMenuTitle());
        setFromPhones(phones);
    }

    private var oldPhones as Phones = noPhones;

    function updateFromPhones(phones as Phones) as Void {
        if (debug) { _3(L_PHONES_VIEW, "updatingFromPhones", phones); }
        if (objectsEqual(oldPhones, phones)) {
            if (debug) { _2(L_PHONES_VIEW, "phonesNotChanged"); }
            return;
        }
        if (debug) { _2(L_PHONES_VIEW, "phonesChanged"); }
        deleteExistingItems();
        setFromPhones(phones);
        workaroundNoRedrawForMenu2(self);
    }

    private function deleteExistingItems() as Void {
        var oldPhonesCount = oldPhones.size();
        var menuItemCount;
        if (oldPhonesCount == 0) {
            menuItemCount = 1; // There should be a "No contacts", "Check Android" or "Syncing" item
        } else {
            menuItemCount = oldPhonesCount;
        }
        menuItemCount += predefinedItemsCount;
        deleteNMenuItems(self, menuItemCount);
    }

    private function setFromPhones(phones as Phones) as Void {
        var focusedItemId = getFocusedPhonesViewItemId();
        var focus = null as Lang.Number or Null;
        var phonesCount = phones.size();
        if (phonesCount > 0) {
            for (var i = 0; i < phonesCount; i++) {
                var phone = phones[i];
                var specialItem = specialItemForPhone(phone);
                if (specialItem != null) {
                    addItem(specialItem);
                    continue;
                }
                var item = new WatchUi.MenuItem(
                    getPhoneName(phone), // label
                    AppSettings.isShowingPhoneNumbersEnabled ? getPhoneNumber(phone) : null, // subLabel
                    phone, // identifier
                    {}
                );
                if (getPhoneId(phone) == focusedItemId) {
                    focus = i;
                }
                addItem(item);
            }
        } else {
            if (PermissionInfoManip.hasStarredContactsPermission()) {
                addItem(new WatchUi.MenuItem("Not selected", "", noPhonesMenuItemId, {}));
            } else {
                addItem(new WatchUi.MenuItem("Grant Access:", "Contacts", noPhonesMenuItemId, {}));
            }
        }

        for (var i = 0; i < predefinedItemsCount; i++) {
            addItem(predefinedItems[i]);
        }
        
        if (focus != null) {
           setFocus(focus);
        }
        oldPhones = phones;
    }
}

const noPhonesMenuItemId as Lang.Number = -1;
const crashMeMenuItemId as Lang.Number = -2;

function specialItemForPhone(phone as Phone) as WatchUi.MenuItem | Null {
    var phoneName = getPhoneName(phone);
    if (phoneName.equals("Crash Me")) {
        return new WatchUi.MenuItem(
            phoneName, // label
            sourceVersion, // subLabel
            phone, // identifier
            {}
        );
    }
    return null;
}
