import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class CallInProgressView extends ExtendedMenu2 {
    function initialize(phone as Phone, optimistic as Lang.Boolean) {
        var texts = textsForCallInProgress(phone);
        var title = texts[:title] as Lang.String;
        if (optimistic) {
            title = pendingText(title);
        }
        ExtendedMenu2.initialize();
        setTitle(embeddingHeadsetStatusRep(title));
        var actions = texts[:actions] as CallInProgressActions;
        populateFromActions(actions);
    }

    private function populateFromActions(actions as CallInProgressActions) as Void {
        for (var i = 0; i < actions.size(); ++i) {
            var action = actions[i] as CallInProgressActionSelector;
            var command = action[:command] as Lang.String;
            var item = new WatchUi.MenuItem(
                action[:prompt] as Lang.String, // label
                action[:subLabel] as Lang.String or Null, // subLabel
                command, // identifier
                null // options
            );
            addItem(item);
        }
    }

    private function updateInPlaceFromActions(actions as CallInProgressActions) as Void {
        if (debug) { _3(L_APP, "updatingInPlace", actions); }
        beginUpdate();
        var j = 0;
        for (var i = 0; i < actions.size(); ++i) {
            var action = actions[i] as CallInProgressActionSelector;
            var command = action[:command] as Lang.String;
            var item = new WatchUi.MenuItem(
                action[:prompt] as Lang.String, // label
                action[:subLabel] as Lang.String or Null, // subLabel
                command, // identifier
                null // options
            );
            // It's possible that the menu item at index j is not the one we want to update.
            // We delete all such items, either to the end or until we find the item to update.
            while (j < menuItemCount) {
                var existingItem = getItem(j) as WatchUi.MenuItem;
                if ((existingItem.getId() as Lang.String).equals(command)) {
                    if (debug) { _3(L_APP, "existingItem", [j, existingItem.getId()]); }
                    break;
                }
                if (debug) { _3(L_APP, "deletingItem", [j, existingItem.getId()]); }
                deleteItem(j);
                // we should not increment j here, since we just deleted an item.
            }
            if (j < menuItemCount) {
                // We found the item to update.
                if (debug) { _3(L_APP, "updatingItem", [j, item.getId()]); }
                updateItem(item, j);
            } else {
                if (debug) { _3(L_APP, "addingItem", [j, item.getId()]); }
                addItem(item);
            }
            j++;
        }
        if (j < menuItemCount) {
            // We have more items than we need.
            if (debug) { _3(L_APP, "deletingRemainingItemsFrom", j); }
            deleteItems(j, menuItemCount - j);
        }
        endUpdate();
    }

    function updateFromPhone(phone as Phone, optimistic as Lang.Boolean) as Void {
        var texts = textsForCallInProgress(phone);
        var title = texts[:title] as Lang.String;
        if (optimistic) {
            title = pendingText(title);
        }
        setTitle(embeddingHeadsetStatusRep(title));

        var actions = texts[:actions] as CallInProgressActions;
        if (actions.size() != menuItemCount) {
            deleteAllItems();
            populateFromActions(actions);
        } else {
            updateInPlaceFromActions(actions);
        }
        workaroundNoRedrawForMenu2(self);
    }
}
