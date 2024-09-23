using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.System;

const L_PHONES_VIEW as LogComponent = "phonesView";

class PhonesView extends WatchUi.Menu2 {

    function predefinedItems() as Lang.Array<WatchUi.MenuItem> {
        return [
            recentsMenuItem("• "),
            settingsMenuItem("• ")
        ];
    }

    var predefinedItemsCount as Lang.Number = predefinedItems().size();

    function initialize(phones as Phones) {
        WatchUi.Menu2.initialize({
            :title => "Favorites"
        });
        setFromPhones(phones);
    }

    private var oldPhones as Phones = [] as Phones;

    function updateFromPhones(phones as Phones) as Void {
        _3(L_PHONES_VIEW, "updatingFromPhones", phones);
        if (oldPhones.toString().equals(phones.toString())) {
            _2(L_PHONES_VIEW, "phonesNotChanged");
            return;
        }
        _2(L_PHONES_VIEW, "phonesChanged");
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
            menuItemCount = oldPhonesCount + predefinedItems().size();
        }
        for (var i = 0; i < menuItemCount; i++) {
            var existed = deleteItem(0);
            if (existed == null) {
                System.error("Failed to delete menu item at index " + i);
            }
        }
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
                    getPhoneNumber(phone), // subLabel
                    phone, // identifier
                    {}
                );
                if (getPhoneId(phone) == focusedItemId) {
                    focus = i;
                }
                addItem(item);
            }
        } else {
            addItem(new WatchUi.MenuItem("No contacts selected", "", noPhonesMenuItemId, {}));
        }

        var predefinedItems = predefinedItems();
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
    var phoneName = phone["name"] as Lang.String;
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
