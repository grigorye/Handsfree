using Toybox.Communications;
using Toybox.Lang;

const L_INCOMING as LogComponent = new LogComponent("incoming", true);

(:glance)
const L_INCOMING_INIT as LogComponent = new LogComponent("incoming", false);

(:glance)
class InAppIncomingMessageDispatcher {
    var readyToSync as Lang.Boolean = false;

    function launch() as Void {
        _([L_INCOMING_INIT, "registerForPhoneAppMessages"]);
        Communications.registerForPhoneAppMessages(method(:onPhone));
        readyToSync = true;
    }
    
    (:typecheck(disableGlanceCheck))
    function onPhone(msg as Communications.Message) as Void {
        if (!readyToSync) {
            _([L_INCOMING, "flushedMsg", msg]);
            return;
        }
        if (routedToMainUI) {
            didSeeIncomingMessageWhileRoutedToMainUI();
        }
        handleRemoteMessage(msg);
    }
}
