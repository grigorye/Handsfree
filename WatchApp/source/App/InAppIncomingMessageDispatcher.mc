using Toybox.Communications;
using Toybox.Lang;

const L_INCOMING as LogComponent = "incoming";

const L_INCOMING_INIT as LogComponent = "incoming";

class InAppIncomingMessageDispatcher {
    private var readyToSync as Lang.Boolean = false;

    function launch() as Void {
        if (debug) { _2(L_INCOMING_INIT, "registerForPhoneAppMessages"); }
        Communications.registerForPhoneAppMessages(method(:onPhoneAppMessage));
        readyToSync = true;
    }
    
    function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
        if (!readyToSync) {
            if (AppSettings.isFlushIncomingMessagesOnLaunchEnabled) {
                if (debug) { _3(L_INCOMING, "flushedMsg", msg.data); }
                return;
            } else {
                if (debug) { _3(L_INCOMING, "flushableMsg", msg.data); }
            }
        }
        if (routedToMainUI) {
            didSeeIncomingMessageWhileRoutedToMainUI();
        }
        handleRemoteMessage(msg);
    }
}
