using Toybox.WatchUi;
using Toybox.Lang;

class CallInProgressView extends Toybox.WatchUi.Confirmation {
    function initialize(phone as Phone) {
        var texts = textsForCallInProgress(phone);
        var message = texts[:title] + "\n" + texts[:prompt];
        Confirmation.initialize(message);
    }
}
