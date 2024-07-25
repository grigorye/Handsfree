using Toybox.WatchUi;
using Toybox.Lang;

class CallInProgressView2 extends WatchUi.Menu2 {
    function initialize(phone as Phone) {
        var texts = textsForCallInProgress(phone);
        WatchUi.Menu2.initialize({
            :title => texts[:title] as Lang.String
        });

        var promptItem = new WatchUi.MenuItem(
            texts[:prompt] as Lang.String, // label
            null, // subLabel
            texts[:action] as Lang.String, // identifier
            null // options
        );

        addItem(promptItem);
    }
}
