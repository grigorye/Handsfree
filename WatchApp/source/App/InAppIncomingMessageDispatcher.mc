using Toybox.Communications;
using Toybox.Lang;

const L_INCOMING as LogComponent = "incoming";

(:glance)
const L_INCOMING_INIT as LogComponent = "incoming";

(:glance)
class InAppIncomingMessageDispatcher {
    var readyToSync as Lang.Boolean = false;

    function launch() as Void {
        _([L_INCOMING_INIT, "registerForPhoneAppMessages"]);
        Communications.registerForPhoneAppMessages(method(:onPhoneAppMessage));
        readyToSync = true;
    }
    
    (:typecheck(disableGlanceCheck))
    function onPhoneAppMessage(msg as Communications.Message) as Void {
        if (!readyToSync) {
            _([L_INCOMING, "flushedMsg", msg.data]);
            return;
        }
        if (routedToMainUI) {
            didSeeIncomingMessageWhileRoutedToMainUI();
        }
        handleRemoteMessage(msg);
    }
}
