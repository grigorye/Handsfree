using Toybox.WatchUi;
using Toybox.Lang;

const L_USER_ACTION as LogComponent = "userAction";
const L_USER_ACTION_DEBUG as LogComponent = "userAction";

class CallInProgressViewDelegate extends WatchUi.Menu2InputDelegate {
    var phone as Phone;

    function initialize(phone as Phone) {
        self.phone = phone;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        if (debug) { _3(L_USER_ACTION, "callInProgress.onSelect", { "phone" => phone, "item" => item.getId() }); }
        switch (item.getId() as CallInProgressAction) {
            case CALL_IN_PROGRESS_ACTION_ACCEPT: {
                if (debug) { _2(L_USER_ACTION_DEBUG, "accept"); }
                popView(WatchUi.SLIDE_IMMEDIATE);
                acceptIncomingCall(phone);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_HANGUP: {
                if (debug) { _2(L_USER_ACTION_DEBUG, "hangup"); }
                popView(WatchUi.SLIDE_IMMEDIATE);
                hangupCallInProgress(phone);
                break;
            }
            case CALL_IN_PROGRESS_ACTION_REJECT: {
                if (debug) { _2(L_USER_ACTION_DEBUG, "reject"); }
                popView(WatchUi.SLIDE_IMMEDIATE);
                rejectIncomingCall(phone);
                break;
            }
        }
    }

    function onBack() {
        if (debug) { _2(L_USER_ACTION, "callInProgress.onBack"); }
        exitToSystemFromCurrentView();
    }
}
