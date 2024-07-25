using Toybox.WatchUi;
using Toybox.Lang;

class CallInProgressView2 extends WatchUi.Menu2 {
    function initialize(phone as Phone) {
        var texts = textsForCallInProgress(phone);
        WatchUi.Menu2.initialize({
            :title => texts[:title] as Lang.String
        });

        var actions = texts[:actions] as Lang.Array<Lang.Dictionary<Lang.Symbol, Lang.String>>;
        for (var i = 0; i < actions.size(); ++i) {
            var action = actions[i] as Lang.Dictionary<Lang.Symbol, Lang.String>;
            var item = new WatchUi.MenuItem(
                action[:prompt] as Lang.String, // label
                null, // subLabel
                action[:command] as Lang.String, // identifier
                null // options
            );
            addItem(item);
        }
    }
}
