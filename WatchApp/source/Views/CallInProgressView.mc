import Toybox.WatchUi;
import Toybox.Lang;

class CallInProgressView extends WatchUi.Menu2 {
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
        for (var i = 0; i < actions.size(); ++i) {
            var action = actions[i] as CallInProgressActionSelector;
            var item = new WatchUi.MenuItem(
                action[:prompt] as Lang.String, // label
                null, // subLabel
                action[:command] as Lang.String, // identifier
                null // options
            );
            addItem(item);
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
        for (var i = 0; i < actions.size(); ++i) {
            var action = actions[i] as CallInProgressActionSelector;
            var item = getItem(findItemById(action[:command] as Lang.String)) as WatchUi.MenuItem;
            item.setLabel(action[:prompt] as Lang.String);
        }
        workaroundNoRedrawForMenu2(self);
    }
}
