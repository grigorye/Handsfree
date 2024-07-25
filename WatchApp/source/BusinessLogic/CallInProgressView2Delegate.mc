using Toybox.WatchUi;
using Toybox.Lang;

class CallInProgressView2Delegate extends WatchUi.Menu2InputDelegate {
    var phone as Phone;

    function initialize(phone as Phone) {
        self.phone = phone;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        dump("onSelectInCallInProgress", { "phone" => phone, "item" => item.getId() });
        switch (item.getId() as CallInProgressAction) {
            case CALL_IN_PROGRESS_ACTION_ACCEPT: {
                dump("accept", true);
                popView(WatchUi.SLIDE_IMMEDIATE);
                onCallInProgressActionConfirmed(phone, true);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_HANGUP: {
                dump("hangup", true);
                popView(WatchUi.SLIDE_IMMEDIATE);
                onCallInProgressActionConfirmed(phone, true);
                break;
            }
        }
    }

    function onBack() {
        dump("onBackInCallInProgress", true);
        popView(WatchUi.SLIDE_IMMEDIATE);
        onCallInProgressActionConfirmed(phone, false);
    }
}
