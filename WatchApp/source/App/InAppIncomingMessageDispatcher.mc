using Toybox.Communications;
using Toybox.Lang;

const L_INCOMING as LogComponent = "incoming";

const L_INCOMING_INIT as LogComponent = "incoming";

class InAppIncomingMessageDispatcher {
    private var readyToSync as Lang.Boolean = false;

    function launch() as Void {
        _2(L_INCOMING_INIT, "registerForPhoneAppMessages");
        Communications.registerForPhoneAppMessages(method(:onPhoneAppMessage));
        readyToSync = true;
    }
    
    function onPhoneAppMessage(msg as Communications.Message) as Void {
        if (!readyToSync) {
            _3(L_INCOMING, "flushedMsg", msg.data);
            return;
        }
        if (routedToMainUI) {
            didSeeIncomingMessageWhileRoutedToMainUI();
        }
        handleRemoteMessage(msg);
    }
}
