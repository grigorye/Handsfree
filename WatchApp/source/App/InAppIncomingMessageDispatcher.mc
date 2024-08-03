using Toybox.Communications;
using Toybox.Lang;

(:glance)
class InAppIncomingMessageDispatcher {
    var readyToSync as Lang.Boolean = false;

    function launch() as Void {
        dump("registerForPhoneAppMessages", true);
        Communications.registerForPhoneAppMessages(method(:onPhone));
        readyToSync = true;
    }
    
    (:typecheck(disableGlanceCheck))
    function onPhone(msg as Communications.Message) as Void {
        if (!readyToSync) {
            dump("flushedMsg", msg);
            return;
        }
        if (routedToMainUI) {
            didSeeIncomingMessageWhileRoutedToMainUI();
        }
        handleRemoteMessage(msg);
    }
}
