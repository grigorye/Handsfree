using Toybox.WatchUi;
using Toybox.Lang;

const L_USER_ACTION as LogComponent = new LogComponent("userAction", true);
const L_USER_ACTION_DEBUG as LogComponent = new LogComponent("userAction", false);

class CallInProgressViewDelegate extends WatchUi.Menu2InputDelegate {
    var phone as Phone;

    function initialize(phone as Phone) {
        self.phone = phone;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        _([L_USER_ACTION, "callInProgress.onSelect", { "phone" => phone, "item" => item.getId() }]);
        switch (item.getId() as CallInProgressAction) {
            case CALL_IN_PROGRESS_ACTION_ACCEPT: {
                _([L_USER_ACTION_DEBUG, "accept"]);
                popView(WatchUi.SLIDE_IMMEDIATE);
                acceptIncomingCall(phone);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_HANGUP: {
                _([L_USER_ACTION_DEBUG, "hangup"]);
                popView(WatchUi.SLIDE_IMMEDIATE);
                hangupCallInProgress(phone);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_REJECT: {
                _([L_USER_ACTION_DEBUG, "reject"]);
                popView(WatchUi.SLIDE_IMMEDIATE);
                rejectIncomingCall(phone);
                break;
            }
        }
    }

    function onBack() {
        _([L_USER_ACTION, "callInProgress.onBack"]);
        popView(WatchUi.SLIDE_IMMEDIATE);
        exitToSystemFromPhonesView();
    }
}
