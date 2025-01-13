import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class CallInProgressView extends WatchUi.Menu2 {
    var actionsCount as Lang.Number;

    function initialize(phone as Phone, optimistic as Lang.Boolean) {
        var texts = textsForCallInProgress(phone);
        var title = texts[:title] as Lang.String;
        if (optimistic) {
            title = "|" + title + "|";
        }
        Menu2.initialize({
            :title => title
        });

        var actions = texts[:actions] as CallInProgressActions;
        populateFromActions(actions);
        self.actionsCount = actions.size();
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
        for (var i = 0; i < actions.size(); ++i) {
            var action = actions[i] as CallInProgressActionSelector;
            var command = action[:command] as Lang.String;
            var existingIndex = findItemById(command) as Lang.Number;
            if (existingIndex != -1) {
                var item = getItem(existingIndex) as WatchUi.MenuItem;
                item.setLabel(action[:prompt] as Lang.String);
                item.setSubLabel(action[:subLabel] as Lang.String or Null);
            } else {
                var item = new WatchUi.MenuItem(
                    action[:prompt] as Lang.String, // label
                    action[:subLabel] as Lang.String or Null, // subLabel
                    command, // identifier
                    null // options
                );
                var existed = deleteItem(i);
                if (existed == null) {
                    System.error("Failed to replace item at index " + i);
                }
                addItem(item);
            }
        }
    }

    function updateFromPhone(phone as Phone, optimistic as Lang.Boolean) as Void {
        var texts = textsForCallInProgress(phone);
        var title = texts[:title] as Lang.String;
        if (optimistic) {
            title = "|" + title + "|";
        }
        setTitle(title);

        var actions = texts[:actions] as CallInProgressActions;
        if (actions.size() != self.actionsCount) {
            deleteNMenuItems(self, self.actionsCount);
            populateFromActions(actions);
            self.actionsCount = actions.size();
        } else {
            updateInPlaceFromActions(actions);
        }
        workaroundNoRedrawForMenu2(self);
    }
}
