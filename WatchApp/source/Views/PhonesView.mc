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

    function deleteExistingItems() as Void {
        var accessIssue = oldPhones[PhonesField.accessIssue] as AccessIssue | Null;
        if (accessIssue != null) {
            deleteItem(0); // There should be a single item for access issue
        } else {
            deleteExistingPhoneListItems();
        }
        deleteNMenuItems(self, predefinedItemsCount);
    }

    private function deleteExistingPhoneListItems() as Void {
        var oldPhonesList = oldPhones[PhonesField.phoneList] as PhoneList;
        var oldPhonesCount = oldPhonesList.size();
        var menuItemCount;
        if (oldPhonesCount == 0) {
            menuItemCount = 1; // There should be a "No contacts" item
        } else {
            menuItemCount = oldPhonesCount;
        }
        deleteNMenuItems(self, menuItemCount);
    }

    private function setFromPhones(phones as Phones) as Void {
        var accessIssue = phones[PhonesField.accessIssue] as AccessIssue;
        if (accessIssue != null) {
            switch (accessIssue) {
                case AccessIssues.NoPermission:
                    addItem(new WatchUi.MenuItem("Grant Access:", "Contacts", noPhonesMenuItemId, {}));
                    break;
                case AccessIssues.ReadFailed:
                    addItem(new WatchUi.MenuItem("Read Failed:", "Contacts", noPhonesMenuItemId, {}));
                    break;
                default:
                    System.error("Unknown access issue: " + accessIssue);
            }
        } else {
            var phoneList = phones[PhonesField.phoneList] as PhoneList;
            setFromPhoneList(phoneList);
        }
        addPredefinedMenuItems();
        oldPhones = phones;
    }

    private function setFromPhoneList(phones as PhoneList) as Void {
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
            addItem(new WatchUi.MenuItem("Not selected", "", noPhonesMenuItemId, {}));
        }

        if (focus != null) {
           setFocus(focus);
        }
    }

    private function addPredefinedMenuItems() as Void {
        for (var i = 0; i < predefinedItemsCount; i++) {
            addItem(predefinedItems[i]);
        }
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
