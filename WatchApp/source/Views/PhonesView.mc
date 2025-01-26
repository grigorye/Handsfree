import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

module PhonesScreen {

const L_PHONES_VIEW as LogComponent = "phonesView";

class View extends ExtendedMenu2 {

    const predefinedItems as Lang.Array<WatchUi.MenuItem> = [
        newRecentsMenuItem(),
        newSettingsMenuItem()
    ];

    const predefinedItemsCount as Lang.Number = predefinedItems.size();

    function initialize(phones as Phones) {
        ExtendedMenu2.initialize();
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
        beginUpdate();
        deleteExistingItems();
        setFromPhones(phones);
        endUpdate();
    }

    private function setFromPhones(phones as Phones) as Void {
        var accessIssue = phones[PhonesField_accessIssue] as AccessIssue | Null;
        if (accessIssue != null) {
            addItem(accessIssueMenuItem("Contacts", accessIssue, noPhonesMenuItemId));
        } else {
            var phoneList = phones[PhonesField_phoneList] as PhoneList;
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

}